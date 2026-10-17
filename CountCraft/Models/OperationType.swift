//
//  OperationType.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import Foundation

enum OperationType: String, CaseIterable, Identifiable {
    case addition
    case multiplication
    case exponent
    case sets

    var id: String { rawValue }

    var operandRange: ClosedRange<Int> {
        self == .exponent ? 0...12 : 0...40
    }

    func supports(_ fact: MathFact) -> Bool {
        operandRange.contains(fact.a) && operandRange.contains(fact.b)
    }

    func axisValues(minValue: Int, maxValue: Int, step: Int) -> [Int] {
        let lower = min(max(minValue, operandRange.lowerBound), operandRange.upperBound)
        let upper = min(max(maxValue, operandRange.lowerBound), operandRange.upperBound)
        let clampedStep = min(max(step, 1), 10)
        return Array(stride(from: min(lower, upper), through: max(lower, upper), by: clampedStep))
    }

    var title: String {
        switch self {
        case .addition:
            return "Add"
        case .multiplication:
            return "Multiply"
        case .exponent:
            return "Exponents"
        case .sets:
            return "Sets"
        }
    }

    var symbol: String {
        switch self {
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

    var maxResult: Int {
        switch self {
        case .addition:
            return 24
        case .multiplication:
            return 144
        case .exponent:
            return 1000000
        case .sets:
            return 1716
        }
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
        case .sets:
            return combinationsCount(setSize: fact.a, maxElement: fact.b)
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

    private func combinationsCount(setSize: Int, maxElement: Int) -> Int {
        let available = maxElement + 1
        return Combinatorics.choose(n: available, k: setSize)
    }
}
