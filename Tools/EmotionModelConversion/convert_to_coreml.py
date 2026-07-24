import json
import os

import coremltools as ct
import numpy as np
import torch
from transformers import AutoModelForSequenceClassification, AutoTokenizer

MODEL_ID = "Jinuuuu/KoELECTRA_fine_tunning_emotion"
MAX_LENGTH = 128
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "output")


class EmotionClassifierWrapper(torch.nn.Module):
    def __init__(self, hf_model):
        super().__init__()
        self.hf_model = hf_model

    def forward(self, input_ids, attention_mask, token_type_ids):
        logits = self.hf_model(
            input_ids=input_ids,
            attention_mask=attention_mask,
            token_type_ids=token_type_ids,
        ).logits
        return torch.nn.functional.softmax(logits, dim=-1)


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    print(f"Loading {MODEL_ID} ...")
    hf_model = AutoModelForSequenceClassification.from_pretrained(MODEL_ID)
    hf_model.eval()
    tokenizer = AutoTokenizer.from_pretrained(MODEL_ID)

    id2label = {int(k): v for k, v in hf_model.config.id2label.items()}
    print("id2label mapping (this determines the class index order):")
    print(json.dumps(id2label, ensure_ascii=False, indent=2))
    with open(os.path.join(OUTPUT_DIR, "id2label.json"), "w") as f:
        json.dump(id2label, f, ensure_ascii=False, indent=2)

    wrapped = EmotionClassifierWrapper(hf_model)

    example_input_ids = torch.zeros((1, MAX_LENGTH), dtype=torch.int32)
    example_attention_mask = torch.ones((1, MAX_LENGTH), dtype=torch.int32)
    example_token_type_ids = torch.zeros((1, MAX_LENGTH), dtype=torch.int32)

    print("Tracing model ...")
    traced = torch.jit.trace(
        wrapped,
        (example_input_ids, example_attention_mask, example_token_type_ids),
    )

    print("Converting to Core ML ...")
    mlmodel = ct.convert(
        traced,
        source="pytorch",
        inputs=[
            ct.TensorType(name="input_ids", shape=(1, MAX_LENGTH), dtype=np.int32),
            ct.TensorType(name="attention_mask", shape=(1, MAX_LENGTH), dtype=np.int32),
            ct.TensorType(name="token_type_ids", shape=(1, MAX_LENGTH), dtype=np.int32),
        ],
        outputs=[ct.TensorType(name="probabilities")],
        minimum_deployment_target=ct.target.iOS16,
        compute_precision=ct.precision.FLOAT32,
    )

    mlpackage_path = os.path.join(OUTPUT_DIR, "EmotionClassifier.mlpackage")
    mlmodel.save(mlpackage_path)
    print(f"Saved Core ML model to {mlpackage_path}")

    tokenizer.save_pretrained(OUTPUT_DIR)
    tokenizer_json_path = os.path.join(OUTPUT_DIR, "tokenizer.json")
    if not os.path.exists(tokenizer_json_path):
        raise RuntimeError(
            "tokenizer.json was not produced — this model's tokenizer may not "
            "support the 'fast' (Rust) tokenizer format. Re-run with "
            "AutoTokenizer.from_pretrained(MODEL_ID, use_fast=True) and inspect "
            "why tokenizer.json wasn't saved."
        )
    print(f"Saved tokenizer.json to {tokenizer_json_path}")

    validate(hf_model, tokenizer, mlmodel, id2label)


def validate(hf_model, tokenizer, mlmodel, id2label):
    fixtures_path = os.path.join(os.path.dirname(__file__), "fixtures", "sample_sentences.json")
    with open(fixtures_path) as f:
        samples = json.load(f)

    print("\nValidating converted model against original PyTorch model:")
    all_match = True
    for sample in samples:
        text = sample["text"]

        # 패딩 없는 순수 토큰 ID (Swift 쪽 토큰화 결과와 1:1로 비교하기 위한 기준값)
        unpadded_ids = tokenizer(text, truncation=True, max_length=MAX_LENGTH)["input_ids"]
        sample["token_ids"] = unpadded_ids

        encoded = tokenizer(
            text,
            padding="max_length",
            truncation=True,
            max_length=MAX_LENGTH,
            return_tensors="pt",
        )

        with torch.no_grad():
            torch_logits = hf_model(**encoded).logits
            torch_probs = torch.nn.functional.softmax(torch_logits, dim=-1).numpy()[0]

        coreml_input = {
            "input_ids": encoded["input_ids"].to(torch.int32).numpy(),
            "attention_mask": encoded["attention_mask"].to(torch.int32).numpy(),
            "token_type_ids": encoded["token_type_ids"].to(torch.int32).numpy(),
        }
        coreml_output = mlmodel.predict(coreml_input)
        coreml_probs = np.array(coreml_output["probabilities"]).reshape(-1)

        torch_label = id2label[int(torch_probs.argmax())]
        coreml_label = id2label[int(coreml_probs.argmax())]
        max_diff = float(np.max(np.abs(torch_probs - coreml_probs)))

        status = "OK" if torch_label == coreml_label and max_diff < 0.01 else "MISMATCH"
        if status == "MISMATCH":
            all_match = False
        print(
            f"[{status}] '{text}' -> torch={torch_label} coreml={coreml_label} "
            f"max_prob_diff={max_diff:.4f} (fixture expected={sample['expected_label']})"
        )

    # 계산된 token_ids를 fixture 파일에 다시 저장한다 — 이 파일은 Task 6에서
    # Swift 토큰화 결과와 정확히 비교하는 유닛 테스트의 정답 기준으로 재사용된다.
    with open(fixtures_path, "w") as f:
        json.dump(samples, f, ensure_ascii=False, indent=2)

    if not all_match:
        raise RuntimeError("Validation failed: see MISMATCH rows above.")
    print("\nAll samples matched between PyTorch and Core ML outputs.")


if __name__ == "__main__":
    main()
