//
//  ReviewGuessesViewModel.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import Foundation
import Combine

final class ReviewGuessesViewModel: ObservableObject {
    @Published var guesses: [PracticeGuess]
    @Published var dateFilter: ReviewDateFilter = .all
    @Published var correctnessFilter: CorrectnessFilter = .all
    @Published var onlyFirstTime = false
    @Published var operationFilter: OperationFilter = .all
    @Published var operandMinA = 0
    @Published var operandMaxA = 12
    @Published var operandMinB = 0
    @Published var operandMaxB = 12
    @Published var activeOperandFilter: OperandFilter?
    @Published var recentFilter: RecentFilter = .all
    @Published var sortDescriptors: [SortDescriptor] = []

    init(guesses: [PracticeGuess]) {
        self.guesses = guesses
    }

    var filteredGuesses: [PracticeGuess] {
        let dateCutoff = dateFilter.cutoffDate
        let filtered = sortedGuesses.filter { guess in
            let dateMatch = dateCutoff.map { guess.timestamp >= $0 } ?? true
            let correctnessMatch = correctnessFilter.matches(guess)
            let firstTimeMatch = !onlyFirstTime || firstTimeGuessIds.contains(guess.id)
            let operationMatch = operationFilter.matches(guess)
            let operandMatch = (operandMinA...operandMaxA).contains(guess.a)
                && (operandMinB...operandMaxB).contains(guess.b)
            return dateMatch && correctnessMatch && firstTimeMatch && operationMatch && operandMatch
        }
        let recent = recentFilter.apply(to: filtered)
        return sortDescriptors.isEmpty ? recent : recent.sorted(by: sortComparator)
    }

    private var sortedGuesses: [PracticeGuess] {
        guesses.sorted { $0.timestamp > $1.timestamp }
    }

    private var firstTimeGuessIds: Set<UUID> {
        var earliest: [FactKey: PracticeGuess] = [:]
        for guess in guesses {
            let key = FactKey(a: guess.a, b: guess.b)
            if let current = earliest[key] {
                if guess.timestamp < current.timestamp {
                    earliest[key] = guess
                }
            } else {
                earliest[key] = guess
            }
        }
        return Set(earliest.values.map(\.id))
    }

    private func sortComparator(lhs: PracticeGuess, rhs: PracticeGuess) -> Bool {
        for descriptor in sortDescriptors {
            if let result = compare(lhs, rhs, for: descriptor) {
                return result
            }
        }
        return false
    }

    private func compare(_ lhs: PracticeGuess, _ rhs: PracticeGuess, for descriptor: SortDescriptor) -> Bool? {
        let ascending = descriptor.direction == .ascending
        switch descriptor.key {
        case .operandA:
            return compare(lhs.a, rhs.a, ascending: ascending)
        case .operation:
            return compare(lhs.operation, rhs.operation, ascending: ascending)
        case .operandB:
            return compare(lhs.b, rhs.b, ascending: ascending)
        case .guess:
            return compare(lhs.userAnswer ?? Int.min, rhs.userAnswer ?? Int.min, ascending: ascending)
        case .answer:
            return compare(lhs.correctAnswer, rhs.correctAnswer, ascending: ascending)
        case .check:
            return compareBool(lhs.isCorrect, rhs.isCorrect, ascending: ascending)
        case .difficulty:
            return compare(difficultyRank(lhs), difficultyRank(rhs), ascending: ascending)
        case .timestamp:
            return compare(lhs.timestamp, rhs.timestamp, ascending: ascending)
        }
    }

    private func difficultyRank(_ guess: PracticeGuess) -> Int {
        guard let value = guess.difficulty,
              let difficulty = ChoiceDifficulty(rawValue: value) else {
            return 0
        }
        switch difficulty {
        case .easy:
            return 1
        case .medium:
            return 2
        case .hard:
            return 3
        }
    }

    private func compare<T: Comparable>(_ lhs: T, _ rhs: T, ascending: Bool) -> Bool? {
        if lhs == rhs { return nil }
        return ascending ? (lhs < rhs) : (lhs > rhs)
    }

    private func compareBool(_ lhs: Bool, _ rhs: Bool, ascending: Bool) -> Bool? {
        if lhs == rhs { return nil }
        let left = lhs ? 1 : 0
        let right = rhs ? 1 : 0
        return ascending ? (left < right) : (left > right)
    }
}
