//
//  PracticeModels.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import Foundation

struct MathFact: Identifiable, Hashable {
    let a: Int
    let b: Int

    var id: String { "\(a)-\(b)" }
}

struct FactKey: Hashable {
    let a: Int
    let b: Int
}

struct FactStats {
    var attempts: Int = 0
    var correct: Int = 0
    var lastWasCorrect: Bool?

    var accuracy: Double {
        attempts == 0 ? 0 : Double(correct) / Double(attempts)
    }

    var isMastered: Bool {
        attempts >= 5 && accuracy >= 0.8
    }

    mutating func add(guess: PracticeGuess) {
        attempts += 1
        if guess.isCorrect {
            correct += 1
        }
        lastWasCorrect = guess.isCorrect
    }

    func adding(guess: PracticeGuess) -> FactStats {
        var copy = self
        copy.add(guess: guess)
        return copy
    }
}

struct PracticeMath {
    static func multipleChoiceOptions(
        for answer: Int,
        maxValue: Int,
        difficulty: ChoiceDifficulty = .medium
    ) -> [Int] {
        var values: Set<Int> = [answer]
        while values.count < 4 {
            if let candidate = candidateValue(
                answer: answer,
                maxValue: maxValue,
                difficulty: difficulty
            ) {
                values.insert(candidate)
            }
        }
        return values.shuffled()
    }

    private static func candidateValue(
        answer: Int,
        maxValue: Int,
        difficulty: ChoiceDifficulty
    ) -> Int? {
        guard maxValue > 0 else { return nil }
        let range = 0...maxValue
        var candidate = answer
        var attempts = 0

        while candidate == answer && attempts < 12 {
            let offset = Int.random(in: difficulty.offsetRange)
            if offset == 0 {
                attempts += 1
                continue
            }
            let raw = answer + offset
            candidate = min(max(raw, range.lowerBound), range.upperBound)
            attempts += 1
        }

        if candidate == answer {
            candidate = Int.random(in: range)
            if candidate == answer {
                return nil
            }
        }

        return candidate
    }
}

extension OperationType {
    func answer(for fact: MathFact) -> Int {
        switch self {
        case .addition:
            return fact.a + fact.b
        case .multiplication:
            return fact.a * fact.b
        }
    }
}
