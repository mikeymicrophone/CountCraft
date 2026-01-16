//
//  PracticeModels.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import Foundation
import SwiftUI

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
        for operation: OperationType,
        fact: MathFact,
        maxValue: Int,
        difficulty: ChoiceDifficulty = .medium
    ) -> [Int] {
        let answer = operation.answer(for: fact)
        var values: Set<Int> = [answer]
        if difficulty == .hard, operation == .multiplication {
            let distractors = multiplicationDistractors(
                for: fact,
                answer: answer,
                maxValue: maxValue
            )
            for candidate in distractors where values.count < 4 {
                values.insert(candidate)
            }
        }

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

    private static func multiplicationDistractors(
        for fact: MathFact,
        answer: Int,
        maxValue: Int
    ) -> [Int] {
        var candidates: [Int] = []

        if let reversed = reversedDigits(of: answer), reversed <= maxValue {
            candidates.append(reversed)
        }

        let multiples = uniqueMultiples(for: fact, maxValue: maxValue)
        candidates.append(contentsOf: multiples.prefix(2))

        return Array(Set(candidates)).shuffled()
    }

    private static func uniqueMultiples(for fact: MathFact, maxValue: Int) -> [Int] {
        let aMultiples = multiples(of: fact.a, excluding: fact.b, maxValue: maxValue)
        let bMultiples = multiples(of: fact.b, excluding: fact.a, maxValue: maxValue)
        return Array(Set(aMultiples + bMultiples)).shuffled()
    }

    private static func multiples(of factor: Int, excluding other: Int, maxValue: Int) -> [Int] {
        let limit = 0...12
        return limit
            .map { factor * $0 }
            .filter { $0 <= maxValue && $0 != factor * other }
    }

    private static func reversedDigits(of value: Int) -> Int? {
        guard value >= 10 else { return nil }
        let reversedString = String(String(value).reversed())
        return Int(reversedString)
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

struct NumberFormatting {
    static func string(from value: Int) -> String {
        formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }()
}

struct NumberStyling {
    static let palette: [Color] = [
        .red, .orange, .yellow, .green, .mint, .pink, .cyan,
        .blue, .indigo, .purple, .teal, .brown, .gray
    ]

    static func color(for value: Int, enabled: Bool) -> Color? {
        guard enabled, (0...12).contains(value) else { return nil }
        return palette[value % palette.count]
    }
}

extension OperationType {
    func answer(for fact: MathFact) -> Int {
        switch self {
        case .addition:
            return fact.a + fact.b
        case .multiplication:
            return fact.a * fact.b
        case .exponent:
            return integerPower(base: fact.a, exponent: fact.b)
        }
    }

    private func integerPower(base: Int, exponent: Int) -> Int {
        guard exponent > 0 else { return exponent == 0 ? 1 : 0 }
        var result = 1
        for _ in 0..<exponent {
            result *= base
        }
        return result
    }
}
