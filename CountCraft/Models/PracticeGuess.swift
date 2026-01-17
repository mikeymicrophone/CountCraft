//
//  PracticeGuess.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import Foundation
import SwiftData

@Model
final class PracticeGuess {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var operation: String
    var difficulty: String?
    var a: Int
    var b: Int
    var correctAnswer: Int
    var userAnswer: Int?
    var isCorrect: Bool
    var inputMode: String
    var answersShown: Bool
    var profile: Profile?

    init(
        operation: OperationType,
        difficulty: ChoiceDifficulty,
        a: Int,
        b: Int,
        correctAnswer: Int,
        userAnswer: Int?,
        isCorrect: Bool,
        inputMode: GuessInputMode,
        answersShown: Bool,
        profile: Profile?,
        timestamp: Date = Date()
    ) {
        self.id = UUID()
        self.timestamp = timestamp
        self.operation = operation.rawValue
        self.difficulty = difficulty.rawValue
        self.a = a
        self.b = b
        self.correctAnswer = correctAnswer
        self.userAnswer = userAnswer
        self.isCorrect = isCorrect
        self.inputMode = inputMode.rawValue
        self.answersShown = answersShown
        self.profile = profile
    }
}
