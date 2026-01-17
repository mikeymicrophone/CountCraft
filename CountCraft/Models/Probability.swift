//
//  Probability.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import Foundation

struct Fraction: Equatable {
    let numerator: Int
    let denominator: Int

    init(numerator: Int, denominator: Int) {
        if denominator == 0 {
            self.numerator = 0
            self.denominator = 1
            return
        }
        let sign = denominator < 0 ? -1 : 1
        let gcdValue = Fraction.greatestCommonDivisor(abs(numerator), abs(denominator))
        self.numerator = sign * numerator / gcdValue
        self.denominator = abs(denominator) / gcdValue
    }

    var value: Double {
        Double(numerator) / Double(denominator)
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
        var numerator = 0
        for k in successesAtLeast...trials {
            let ways = Combinatorics.choose(n: trials, k: k)
            let successWays = intPow(successOutcomes, k)
            let failureWays = intPow(failureOutcomes, trials - k)
            numerator += ways * successWays * failureWays
        }
        let denominator = intPow(totalOutcomes, trials)
        return Fraction(numerator: numerator, denominator: denominator)
    }

    private static func intPow(_ base: Int, _ exponent: Int) -> Int {
        guard exponent > 0 else { return exponent == 0 ? 1 : 0 }
        var result = 1
        for _ in 0..<exponent {
            result *= base
        }
        return result
    }
}
