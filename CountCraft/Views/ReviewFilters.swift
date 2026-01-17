//
//  ReviewFilters.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import Foundation

enum ReviewDateFilter: String, CaseIterable, Identifiable {
    case all
    case today
    case lastSeven
    case lastThirty

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "All"
        case .today:
            return "Today"
        case .lastSeven:
            return "Week"
        case .lastThirty:
            return "Month"
        }
    }

    var cutoffDate: Date? {
        let calendar = Calendar.current
        switch self {
        case .all:
            return nil
        case .today:
            return calendar.startOfDay(for: Date())
        case .lastSeven:
            return calendar.date(byAdding: .day, value: -7, to: Date())
        case .lastThirty:
            return calendar.date(byAdding: .day, value: -30, to: Date())
        }
    }
}

enum CorrectnessFilter: String, CaseIterable, Identifiable {
    case all
    case correct
    case incorrect

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "All"
        case .correct:
            return "Correct"
        case .incorrect:
            return "Missed"
        }
    }

    func matches(_ guess: PracticeGuess) -> Bool {
        switch self {
        case .all:
            return true
        case .correct:
            return guess.isCorrect
        case .incorrect:
            return !guess.isCorrect
        }
    }
}

enum OperationFilter: String, CaseIterable, Identifiable {
    case all
    case addition
    case multiplication
    case exponent
    case sets

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "All"
        case .addition:
            return "Add"
        case .multiplication:
            return "Multiply"
        case .exponent:
            return "Exponent"
        case .sets:
            return "Sets"
        }
    }

    func matches(_ guess: PracticeGuess) -> Bool {
        guard case .all = self else {
            let operation = OperationType(rawValue: guess.operation)
            if self == .addition {
                return operation == .addition
            }
            if self == .multiplication {
                return operation == .multiplication
            }
            if self == .exponent {
                return operation == .exponent
            }
            return operation == .sets
        }
        return true
    }

    var symbolLabel: String {
        switch self {
        case .all:
            return "All"
        case .addition:
            return "+"
        case .multiplication:
            return "x"
        case .exponent:
            return "^"
        case .sets:
            return "C"
        }
    }
}

enum OperandFilter: String, Identifiable {
    case a
    case b

    var id: String { rawValue }
}

enum RecentFilter: String, CaseIterable, Identifiable {
    case all
    case last10
    case last25
    case last50

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "All"
        case .last10:
            return "10"
        case .last25:
            return "25"
        case .last50:
            return "50"
        }
    }

    func apply(to guesses: [PracticeGuess]) -> [PracticeGuess] {
        switch self {
        case .all:
            return guesses
        case .last10:
            return Array(guesses.prefix(10))
        case .last25:
            return Array(guesses.prefix(25))
        case .last50:
            return Array(guesses.prefix(50))
        }
    }
}
