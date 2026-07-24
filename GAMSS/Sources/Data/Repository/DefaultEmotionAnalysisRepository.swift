//
//  DefaultEmotionAnalysisRepository.swift
//  GAMSS
//
//  Created by cchanmi on 7/24/26.
//

import CoreML
import Tokenizers

final class DefaultEmotionAnalysisRepository: EmotionAnalysisRepository {
    private static let maxLength = 128
    private static let padTokenId = 0

    private let model: EmotionClassifier
    private let tokenizer: Tokenizer

    private init(model: EmotionClassifier, tokenizer: Tokenizer) {
        self.model = model
        self.tokenizer = tokenizer
    }

    static func make() async throws -> DefaultEmotionAnalysisRepository {
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .all

        guard let model = try? EmotionClassifier(configuration: configuration) else {
            throw EmotionAnalysisError.modelLoadFailed
        }

        guard let tokenizerConfigURL = Bundle.main.url(forResource: "tokenizer", withExtension: "json") else {
            throw EmotionAnalysisError.modelLoadFailed
        }
        let tokenizerFolder = tokenizerConfigURL.deletingLastPathComponent()

        guard let tokenizer = try? await AutoTokenizer.from(modelFolder: tokenizerFolder) else {
            throw EmotionAnalysisError.modelLoadFailed
        }

        return DefaultEmotionAnalysisRepository(model: model, tokenizer: tokenizer)
    }

    func analyze(text: String) async throws -> EmotionAnalysisResult {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw EmotionAnalysisError.emptyInput
        }

        let tokenIds = tokenizer.encode(text: trimmed)
        let (inputIds, attentionMask, tokenTypeIds) = try Self.buildModelInputs(from: tokenIds)

        guard let output = try? model.prediction(
            input_ids: inputIds,
            attention_mask: attentionMask,
            token_type_ids: tokenTypeIds
        ) else {
            throw EmotionAnalysisError.inferenceFailed
        }

        return Self.mapToResult(probabilities: output.probabilities)
    }

    private static func buildModelInputs(
        from tokenIds: [Int]
    ) throws -> (MLMultiArray, MLMultiArray, MLMultiArray) {
        let truncated = Array(tokenIds.prefix(maxLength))
        let realCount = truncated.count
        let padCount = maxLength - realCount

        let paddedIds = truncated + Array(repeating: padTokenId, count: padCount)
        let mask = Array(repeating: 1, count: realCount) + Array(repeating: 0, count: padCount)
        let tokenTypeIds = Array(repeating: 0, count: maxLength)

        let shape: [NSNumber] = [1, NSNumber(value: maxLength)]
        let inputIdsArray = try MLMultiArray(shape: shape, dataType: .int32)
        let attentionMaskArray = try MLMultiArray(shape: shape, dataType: .int32)
        let tokenTypeIdsArray = try MLMultiArray(shape: shape, dataType: .int32)

        for i in 0..<maxLength {
            inputIdsArray[i] = NSNumber(value: paddedIds[i])
            attentionMaskArray[i] = NSNumber(value: mask[i])
            tokenTypeIdsArray[i] = NSNumber(value: tokenTypeIds[i])
        }

        return (inputIdsArray, attentionMaskArray, tokenTypeIdsArray)
    }

    private static func mapToResult(probabilities: MLMultiArray) -> EmotionAnalysisResult {
        var bestIndex = 0
        var bestProbability = 0.0

        for index in 0..<Emotion.orderedByModelIndex.count {
            let probability = probabilities[index].doubleValue
            if probability > bestProbability {
                bestProbability = probability
                bestIndex = index
            }
        }

        return EmotionAnalysisResult(
            emotion: Emotion.orderedByModelIndex[bestIndex],
            confidence: bestProbability
        )
    }
}
