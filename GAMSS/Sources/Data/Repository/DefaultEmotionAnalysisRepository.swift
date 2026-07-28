//
//  DefaultEmotionAnalysisRepository.swift
//  GAMSS
//
//  Created by cchanmi on 7/24/26.
//

import Foundation
import TensorFlowLite
import Tokenizers

// actor로 선언해 interpreter/tokenizer에 대한 동시 접근을 직렬화한다.
// TFLite Interpreter는 스레드 세이프하지 않아서, analyze가 여러 곳에서
// 동시에 호출되면 copy/invoke/output 호출이 서로 레이스할 수 있다.
actor DefaultEmotionAnalysisRepository: EmotionAnalysisRepository {
    private static let maxLength = 128
    private static let padTokenId = 0
    private static let sepTokenId = 3

    private enum InputRole {
        case ids
        case mask
        case tokenType
    }

    private let interpreter: Interpreter
    private let tokenizer: Tokenizer
    private let inputRoles: [InputRole]
    private let inputDataTypes: [Tensor.DataType]

    private init(
        interpreter: Interpreter,
        tokenizer: Tokenizer,
        inputRoles: [InputRole],
        inputDataTypes: [Tensor.DataType]
    ) {
        self.interpreter = interpreter
        self.tokenizer = tokenizer
        self.inputRoles = inputRoles
        self.inputDataTypes = inputDataTypes
    }

    static func make() async throws -> DefaultEmotionAnalysisRepository {
        guard let modelPath = Bundle.main.path(forResource: "emotion_int8", ofType: "tflite") else {
            throw EmotionAnalysisError.modelLoadFailed
        }

        var options = Interpreter.Options()
        // 기기 성능 코어 수에 맞춰 스레드 수를 조정한다. 4는 상한일 뿐,
        // 저사양 기기에서 코어 수 이상으로 스레드를 띄워 컨텍스트 스위칭 비용 절감.
        options.threadCount = min(4, ProcessInfo.processInfo.activeProcessorCount)

        // GPU/Metal/CoreML 델리게이트는 의도적으로 사용하지 않는다.
        // int8 양자화된 gather/embedding 연산이 CoreML 델리게이트 컴파일 경로에서
        // 크래시하는 문제가 이 프로젝트의 Core ML int8 실험에서도 관측된 바 있다.
        guard let interpreter = try? Interpreter(modelPath: modelPath, options: options) else {
            throw EmotionAnalysisError.modelLoadFailed
        }
        guard (try? interpreter.allocateTensors()) != nil else {
            throw EmotionAnalysisError.modelLoadFailed
        }

        guard let (roles, dataTypes) = try? Self.resolveInputSpecs(interpreter) else {
            throw EmotionAnalysisError.modelLoadFailed
        }

        guard let tokenizerConfigURL = Bundle.main.url(forResource: "tokenizer", withExtension: "json") else {
            throw EmotionAnalysisError.modelLoadFailed
        }
        let tokenizerFolder = tokenizerConfigURL.deletingLastPathComponent()

        guard let tokenizer = try? await AutoTokenizer.from(modelFolder: tokenizerFolder) else {
            throw EmotionAnalysisError.modelLoadFailed
        }

        return DefaultEmotionAnalysisRepository(
            interpreter: interpreter,
            tokenizer: tokenizer,
            inputRoles: roles,
            inputDataTypes: dataTypes
        )
    }

    // 입력 텐서 이름 → role, dtype을 로드 시점에 한 번 resolve해 캐싱한다.
    // 모델 재export로 텐서 순서/이름이 바뀌면 로드 시점에 곧바로 실패하게 한다.
    private static func resolveInputSpecs(
        _ interpreter: Interpreter
    ) throws -> ([InputRole], [Tensor.DataType]) {
        var roles: [InputRole] = []
        var dataTypes: [Tensor.DataType] = []
        for index in 0..<interpreter.inputTensorCount {
            let tensor = try interpreter.input(at: index)
            switch tensor.name {
            case "serving_default_input_ids:0":
                roles.append(.ids)
            case "serving_default_attention_mask:0":
                roles.append(.mask)
            case "serving_default_token_type_ids:0":
                roles.append(.tokenType)
            default:
                throw EmotionAnalysisError.modelLoadFailed
            }
            dataTypes.append(tensor.dataType)
        }
        return (roles, dataTypes)
    }

    func analyze(text: String) async throws -> EmotionAnalysisResult {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw EmotionAnalysisError.emptyInput
        }

        let tokenIds = tokenizer.encode(text: trimmed)
        let (inputIds, attentionMask, tokenTypeIds) = Self.buildModelInputs(from: tokenIds)

        do {
            try writeInputs(inputIds: inputIds, attentionMask: attentionMask, tokenTypeIds: tokenTypeIds)
            try interpreter.invoke()
            let outputTensor = try interpreter.output(at: 0)
            return Self.mapToResult(outputData: outputTensor.data)
        } catch {
            Log.error("감정 분석 추론 실패: \(error)")
            throw EmotionAnalysisError.inferenceFailed
        }
    }

    private func writeInputs(inputIds: [Int], attentionMask: [Int], tokenTypeIds: [Int]) throws {
        for index in 0..<inputRoles.count {
            let values: [Int]
            switch inputRoles[index] {
            case .ids: values = inputIds
            case .mask: values = attentionMask
            case .tokenType: values = tokenTypeIds
            }
            let data = Self.serialize(values, as: inputDataTypes[index])
            try interpreter.copy(data, toInputAt: index)
        }
    }

    private static func serialize(_ values: [Int], as dataType: Tensor.DataType) -> Data {
        if dataType == .int64 {
            var data = Data(capacity: values.count * MemoryLayout<Int64>.size)
            for value in values {
                var int64Value = Int64(value)
                withUnsafeBytes(of: &int64Value) { data.append(contentsOf: $0) }
            }
            return data
        }
        var data = Data(capacity: values.count * MemoryLayout<Int32>.size)
        for value in values {
            var int32Value = Int32(value)
            withUnsafeBytes(of: &int32Value) { data.append(contentsOf: $0) }
        }
        return data
    }

    private static func buildModelInputs(
        from tokenIds: [Int]
    ) -> (ids: [Int], mask: [Int], tokenType: [Int]) {
        // Python은 truncation 시 마지막 [SEP]를 항상 보존한다. 단순히 앞에서
        // maxLength개만 자르면 [SEP]가 잘려나가 학습 때와 다른 시퀀스가 되므로,
        // 여기서도 앞 maxLength-1개 + [SEP]로 동일하게 맞춘다.
        let truncated: [Int]
        if tokenIds.count > maxLength {
            truncated = Array(tokenIds.prefix(maxLength - 1)) + [sepTokenId]
        } else {
            truncated = tokenIds
        }
        let realCount = truncated.count
        let padCount = maxLength - realCount

        let paddedIds = truncated + Array(repeating: padTokenId, count: padCount)
        let mask = Array(repeating: 1, count: realCount) + Array(repeating: 0, count: padCount)
        let tokenTypeIds = Array(repeating: 0, count: maxLength)

        return (paddedIds, mask, tokenTypeIds)
    }

    private static func mapToResult(outputData: Data) -> EmotionAnalysisResult {
        let classCount = Emotion.orderedByModelIndex.count
        var logits = [Float](repeating: 0, count: classCount)
        _ = logits.withUnsafeMutableBytes { outputData.copyBytes(to: $0) }

        let maxLogit = logits.max() ?? 0
        let exponentials = logits.map { expf($0 - maxLogit) }
        let sumOfExponentials = exponentials.reduce(0, +)
        let probabilities = exponentials.map { $0 / sumOfExponentials }

        var bestIndex = 0
        var bestProbability: Float = 0
        for (index, probability) in probabilities.enumerated() where probability > bestProbability {
            bestProbability = probability
            bestIndex = index
        }

        return EmotionAnalysisResult(
            emotion: Emotion.orderedByModelIndex[bestIndex],
            confidence: Double(bestProbability)
        )
    }
}
