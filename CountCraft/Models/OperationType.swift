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

    var id: String { rawValue }
    var title: String {
        switch self {
        case .addition:
            return "Add"
        case .multiplication:
            return "Multiply"
        case .exponent:
            return "Exponents"
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
