//
//  Probability.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import Foundation

struct Fraction: Equatable {
    let numerator: Decimal
    let denominator: Decimal

    init(numerator: Int, denominator: Int) {
        if denominator == 0 {
            self.numerator = 0
            self.denominator = 1
            return
        }
        let sign = denominator < 0 ? -1 : 1
        let gcdValue = Fraction.greatestCommonDivisor(abs(numerator), abs(denominator))
        self.numerator = Decimal(sign * numerator / gcdValue)
        self.denominator = Decimal(abs(denominator) / gcdValue)
    }

    init(numerator: Decimal, denominator: Decimal) {
        if denominator == 0 {
            self.numerator = 0
            self.denominator = 1
            return
        }
        if denominator < 0 {
            self.numerator = -numerator
            self.denominator = -denominator
        } else {
            self.numerator = numerator
            self.denominator = denominator
        }
    }

    var value: Double {
        NSDecimalNumber(decimal: numerator).doubleValue / NSDecimalNumber(decimal: denominator).doubleValue
    }

    var formatted: String {
        "\(NumberFormatting.string(from: numerator))/\(NumberFormatting.string(from: denominator))"
    }

    private static func greatestCommonDivisor(_ a: Int, _ b: Int) -> Int {
        var a = a
        var b = b
        while b != 0 {
            let temp = b
            b = a % b
            a = temp
        }
        return max(a, 1)
    }
}

struct Probability {
    static func atLeastSuccesses(
        trials: Int,
        successesAtLeast: Int,
        successOutcomes: Int,
        totalOutcomes: Int
    ) -> Fraction {
        guard trials >= 0, totalOutcomes > 0, successOutcomes >= 0 else {
            return Fraction(numerator: 0, denominator: 1)
        }
        if successesAtLeast <= 0 {
            return Fraction(numerator: 1, denominator: 1)
        }
        if successesAtLeast > trials {
            return Fraction(numerator: 0, denominator: 1)
        }

        let failureOutcomes = max(totalOutcomes - successOutcomes, 0)
        var numerator = Decimal(0)
        for k in successesAtLeast...trials {
            let ways = Combinatorics.choose(n: trials, k: k)
            let successWays = decimalPow(successOutcomes, k)
            let failureWays = decimalPow(failureOutcomes, trials - k)
            let term = Decimal(ways) * successWays * failureWays
            numerator += term
        }
        let denominator = decimalPow(totalOutcomes, trials)
        return Fraction(numerator: numerator, denominator: denominator)
    }

    private static func decimalPow(_ base: Int, _ exponent: Int) -> Decimal {
        guard exponent > 0 else { return exponent == 0 ? 1 : 0 }
        var result = Decimal(1)
        let baseDecimal = Decimal(base)
        for _ in 0..<exponent {
            result *= baseDecimal
        }
        return result
    }
}
