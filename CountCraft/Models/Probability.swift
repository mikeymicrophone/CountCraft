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
        let gcdValue = Combinatorics.greatestCommonDivisor(numerator, denominator)
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
        let num = NSDecimalNumber(decimal: numerator).doubleValue
        let den = NSDecimalNumber(decimal: denominator).doubleValue
        guard den != 0, num.isFinite, den.isFinite else { return 0 }
        return num / den
    }

    var formatted: String {
        "\(NumberFormatting.string(from: numerator))/\(NumberFormatting.string(from: denominator))"
    }
}

struct Probability {
    private static let maxDecimalPowerLimit = 1e35

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

        let (effSuccess, effTotal) = effectiveOutcomes(
            trials: trials,
            successOutcomes: successOutcomes,
            totalOutcomes: totalOutcomes
        )

        guard pow(Double(effTotal), Double(trials)) <= maxDecimalPowerLimit else {
            return approximateDoubleFraction(
                trials: trials,
                successesAtLeast: successesAtLeast,
                successOutcomes: effSuccess,
                totalOutcomes: effTotal
            )
        }

        let failureOutcomes = max(effTotal - effSuccess, 0)
        var numerator = Decimal(0)
        for k in successesAtLeast...trials {
            let ways = Combinatorics.choose(n: trials, k: k)
            let successWays = decimalPow(effSuccess, k)
            let failureWays = decimalPow(failureOutcomes, trials - k)
            let term = Decimal(ways) * successWays * failureWays
            numerator += term
        }
        let denominator = decimalPow(effTotal, trials)
        return Fraction(numerator: numerator, denominator: denominator)
    }

    /// Computes `atLeastSuccesses` for all thresholds `0...trials` in a single $O(\text{trials})$ suffix pass.
    static func columnAtLeastSuccesses(
        trials: Int,
        successOutcomes: Int,
        totalOutcomes: Int
    ) -> [Fraction] {
        guard trials >= 0, totalOutcomes > 0, successOutcomes >= 0 else {
            return []
        }
        if trials == 0 {
            return [Fraction(numerator: 1, denominator: 1)]
        }

        let (effSuccess, effTotal) = effectiveOutcomes(
            trials: trials,
            successOutcomes: successOutcomes,
            totalOutcomes: totalOutcomes
        )

        guard pow(Double(effTotal), Double(trials)) <= maxDecimalPowerLimit else {
            return (0...trials).map { threshold in
                approximateDoubleFraction(
                    trials: trials,
                    successesAtLeast: threshold,
                    successOutcomes: effSuccess,
                    totalOutcomes: effTotal
                )
            }
        }

        let failureOutcomes = max(effTotal - effSuccess, 0)
        let denominator = decimalPow(effTotal, trials)
        var results = Array(repeating: Fraction(numerator: 0, denominator: 1), count: trials + 1)
        var runningNumerator = Decimal(0)

        for k in stride(from: trials, through: 1, by: -1) {
            let ways = Combinatorics.choose(n: trials, k: k)
            let successWays = decimalPow(effSuccess, k)
            let failureWays = decimalPow(failureOutcomes, trials - k)
            runningNumerator += Decimal(ways) * successWays * failureWays
            results[k] = Fraction(numerator: runningNumerator, denominator: denominator)
        }
        results[0] = Fraction(numerator: 1, denominator: 1)
        return results
    }

    private static func effectiveOutcomes(
        trials: Int,
        successOutcomes: Int,
        totalOutcomes: Int
    ) -> (Int, Int) {
        if pow(Double(totalOutcomes), Double(trials)) <= maxDecimalPowerLimit {
            return (successOutcomes, totalOutcomes)
        }
        let divisor = Combinatorics.greatestCommonDivisor(successOutcomes, totalOutcomes)
        return (successOutcomes / divisor, totalOutcomes / divisor)
    }

    private static func approximateDoubleFraction(
        trials: Int,
        successesAtLeast: Int,
        successOutcomes: Int,
        totalOutcomes: Int
    ) -> Fraction {
        if successesAtLeast <= 0 {
            return Fraction(numerator: 1, denominator: 1)
        }
        let p = Double(successOutcomes) / Double(totalOutcomes)
        let q = max(1.0 - p, 0.0)
        var probability = 0.0
        for k in successesAtLeast...trials {
            let ways = Double(Combinatorics.choose(n: trials, k: k))
            probability += ways * pow(p, Double(k)) * pow(q, Double(trials - k))
        }
        let clamped = min(max(probability, 0.0), 1.0)
        let scale = 1_000_000
        return Fraction(numerator: Int((clamped * Double(scale)).rounded()), denominator: scale)
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
