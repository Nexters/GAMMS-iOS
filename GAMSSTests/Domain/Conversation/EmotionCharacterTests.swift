//
//  EmotionCharacterTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

import XCTest
@testable import GAMSS

final class EmotionCharacterTests: XCTestCase {
    func test_displayName_isKoreanForEveryCase() {
        XCTAssertEqual(EmotionCharacter.joy.displayName, "기쁨이")
        XCTAssertEqual(EmotionCharacter.sadness.displayName, "슬픔이")
        XCTAssertEqual(EmotionCharacter.anger.displayName, "분노")
        XCTAssertEqual(EmotionCharacter.anxiety.displayName, "불안")
        XCTAssertEqual(EmotionCharacter.prickly.displayName, "까칠이")
        XCTAssertEqual(EmotionCharacter.quirky.displayName, "엉뚱이")
    }

    func test_allCases_hasExactlySixCharacters() {
        XCTAssertEqual(EmotionCharacter.allCases.count, 6)
    }

    func test_pickerLabel_isShortKoreanWithoutCharacterSuffix() {
        XCTAssertEqual(EmotionCharacter.joy.pickerLabel, "기쁨")
        XCTAssertEqual(EmotionCharacter.sadness.pickerLabel, "슬픔")
        XCTAssertEqual(EmotionCharacter.anger.pickerLabel, "분노")
        XCTAssertEqual(EmotionCharacter.anxiety.pickerLabel, "불안")
        XCTAssertEqual(EmotionCharacter.prickly.pickerLabel, "까칠")
        XCTAssertEqual(EmotionCharacter.quirky.pickerLabel, "엉뚱")
    }

    func test_cardTitle_isFixedGuidePhraseForEveryCase() {
        XCTAssertEqual(EmotionCharacter.joy.cardTitle, "오늘 기~쁘네")
        XCTAssertEqual(EmotionCharacter.sadness.cardTitle, "오늘 슬~프네")
        XCTAssertEqual(EmotionCharacter.anger.cardTitle, "오늘 화~나네")
        XCTAssertEqual(EmotionCharacter.anxiety.cardTitle, "오늘 불~안하네")
        XCTAssertEqual(EmotionCharacter.prickly.cardTitle, "오늘 까~칠하네")
        XCTAssertEqual(EmotionCharacter.quirky.cardTitle, "오늘 엉~뚱하네")
    }

    func test_cardIllustrationImageName_isFixedAssetNameForEveryCase() {
        XCTAssertEqual(EmotionCharacter.joy.cardIllustrationImageName, "cardEmotionJoy")
        XCTAssertEqual(EmotionCharacter.sadness.cardIllustrationImageName, "cardEmotionSadness")
        XCTAssertEqual(EmotionCharacter.anger.cardIllustrationImageName, "cardEmotionAnger")
        XCTAssertEqual(EmotionCharacter.anxiety.cardIllustrationImageName, "cardEmotionAnxiety")
        XCTAssertEqual(EmotionCharacter.prickly.cardIllustrationImageName, "cardEmotionPrickly")
        XCTAssertEqual(EmotionCharacter.quirky.cardIllustrationImageName, "cardEmotionQuirky")
    }

    func test_avatarImageName_isFixedAssetNameForEveryCase() {
        XCTAssertEqual(EmotionCharacter.joy.avatarImageName, "emotionAvatarJoy")
        XCTAssertEqual(EmotionCharacter.sadness.avatarImageName, "emotionAvatarSadness")
        XCTAssertEqual(EmotionCharacter.anger.avatarImageName, "emotionAvatarAnger")
        XCTAssertEqual(EmotionCharacter.anxiety.avatarImageName, "emotionAvatarAnxiety")
        XCTAssertEqual(EmotionCharacter.prickly.avatarImageName, "emotionAvatarPrickly")
        XCTAssertEqual(EmotionCharacter.quirky.avatarImageName, "emotionAvatarQuirky")
    }

    func test_pickerOrder_matchesFigmaGridOrder() {
        XCTAssertEqual(
            EmotionCharacter.pickerOrder,
            [.anger, .quirky, .prickly, .joy, .sadness, .anxiety]
        )
    }

    func test_dominant_noMessages_returnsNil() {
        XCTAssertNil(EmotionCharacter.dominant(in: []))
    }

    func test_dominant_onlyUserMessages_returnsNil() {
        let messages = [makeMessage(sender: .user), makeMessage(sender: .user)]
        XCTAssertNil(EmotionCharacter.dominant(in: messages))
    }

    func test_dominant_returnsMostFrequentCharacterEmotion() {
        let messages = [
            makeMessage(sender: .character(.joy)),
            makeMessage(sender: .character(.anger)),
            makeMessage(sender: .character(.anger)),
            makeMessage(sender: .user),
        ]
        XCTAssertEqual(EmotionCharacter.dominant(in: messages), .anger)
    }

    func test_dominant_tie_prefersEarlierAllCasesOrder() {
        // allCases 순서는 joy, sadness, anger, ... — anger와 sadness가 동률이면 sadness가 이겨야 함.
        let messages = [
            makeMessage(sender: .character(.anger)),
            makeMessage(sender: .character(.sadness)),
        ]
        XCTAssertEqual(EmotionCharacter.dominant(in: messages), .sadness)
    }

    private func makeMessage(sender: MessageSender) -> Message {
        Message(id: 0, conversationId: 0, sender: sender, content: "", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0))
    }
}
