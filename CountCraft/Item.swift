//
//  Item.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import Foundation
import SwiftData

enum OperationType: String, CaseIterable, Identifiable {
    case addition
    case multiplication

    var id: String { rawValue }
    var title: String {
        switch self {
        case .addition:
            return "Add"
        case .multiplication:
            return "Multiply"
        }
    }

    var symbol: String {
        switch self {
        case .addition:
            return "+"
        case .multiplication:
            return "x"
        }
    }

    var maxResult: Int {
        switch self {
        case .addition:
            return 24
        case .multiplication:
            return 144
        }
    }
}

enum GuessInputMode: String, CaseIterable, Identifiable {
    case multipleChoice
    case freeEntry

    var id: String { rawValue }
    var title: String {
        switch self {
        case .multipleChoice:
            return "Multiple Choice"
        case .freeEntry:
            return "Free Entry"
        }
    }
}

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
    }
}
