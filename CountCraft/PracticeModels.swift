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

        var loopGuard = 0
        let maxLoops = 100
        while values.count < 4 && loopGuard < maxLoops {
            loopGuard += 1
            if let candidate = candidateValue(
                answer: answer,
                maxValue: maxValue,
                difficulty: difficulty
            ) {
                values.insert(candidate)
            }
        }

        // Fallback if we couldn't generate enough unique values
        while values.count < 4 {
            let multiplier = values.count + 1
            let fallback = max(0, answer + multiplier * (answer / 10 + 1))
            if !values.contains(fallback) {
                values.insert(fallback)
            } else {
                values.insert(answer * multiplier)
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

        // For large answers, use percentage-based offsets instead of fixed offsets
        let usesProportionalOffset = answer > maxValue / 2
        var candidate = answer
        var attempts = 0

        while candidate == answer && attempts < 12 {
            let offset: Int
            if usesProportionalOffset {
                // Use 5-25% offset based on difficulty
                let percentRange: ClosedRange<Double> = switch difficulty {
                case .easy: 0.15...0.30
                case .medium: 0.08...0.20
                case .hard: 0.03...0.12
                }
                let percent = Double.random(in: percentRange)
                let sign = Bool.random() ? 1 : -1
                offset = sign * max(1, Int(Double(answer) * percent))
            } else {
                offset = Int.random(in: difficulty.offsetRange)
            }

            if offset == 0 {
                attempts += 1
                continue
            }

            // Prevent overflow for very large numbers
            let raw: Int
            if answer > Int.max / 2 {
                raw = answer / 2 + offset
            } else {
                raw = answer + offset
            }

            candidate = max(0, raw)
            attempts += 1
        }

        if candidate == answer {
            // Fallback: generate a value near the answer
            let fallbackOffset = max(1, answer / 10)
            candidate = answer + (Bool.random() ? fallbackOffset : -fallbackOffset)
            candidate = max(0, candidate)
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
