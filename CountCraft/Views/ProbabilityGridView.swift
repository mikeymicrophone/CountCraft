//
//  ProbabilityGridView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import SwiftUI

struct ProbabilityGridView: View {
    let title: String
    let successName: String
    let trialsName: String
    let successOutcomes: Int
    let totalOutcomes: Int
    let format: ProbabilityFormat
    @AppStorage("prefColorCodedNumbers") private var colorCodedNumbers = false
    @AppStorage("prefNumberFont") private var numberFontRaw = NumberFontChoice.rounded.rawValue
    @AppStorage("prefAxisMinX-probability") private var probabilityMinX = 0
    @AppStorage("prefAxisMaxX-probability") private var probabilityMaxX = 12
    @AppStorage("prefAxisMinY-probability") private var probabilityMinY = 0
    @AppStorage("prefAxisMaxY-probability") private var probabilityMaxY = 12

    @State private var activeCell: ProbabilityCellData?

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView([.horizontal, .vertical]) {
                LazyVStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        headerCell("x/y")
                        ForEach(valuesY, id: \.self) { value in
                            headerCell(NumberFormatting.string(from: value), value: value)
                        }
                    }

                    ForEach(valuesX, id: \.self) { threshold in
                        HStack(spacing: 8) {
                            headerCell(">= \(NumberFormatting.string(from: threshold))", value: threshold)
                            ForEach(valuesY, id: \.self) { throwCount in
                                ProbabilityGridCell(
                                    label: probabilityLabel(threshold: threshold, trials: throwCount),
                                    numberStyle: numberStyle,
                                    isDisabled: threshold > throwCount
                                )
                                .onTapGesture {
                                    guard threshold <= throwCount else { return }
                                    activeCell = ProbabilityCellData(
                                        threshold: threshold,
                                        trials: throwCount,
                                        successName: successName,
                                        trialsName: trialsName,
                                        successOutcomes: successOutcomes,
                                        totalOutcomes: totalOutcomes
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .sheet(item: $activeCell) { cell in
            ProbabilityExplanationSheet(
                cell: cell,
                rowValues: valuesX,
                columnValues: valuesY,
                format: format,
                numberStyle: numberStyle,
                onNavigate: { newThreshold, newTrials in
                    guard newThreshold <= newTrials else { return }
                    activeCell = ProbabilityCellData(
                        threshold: newThreshold,
                        trials: newTrials,
                        successName: successName,
                        trialsName: trialsName,
                        successOutcomes: successOutcomes,
                        totalOutcomes: totalOutcomes
                    )
                }
            )
        }
    }

    private var numberStyle: NumberStyle {
        let choice = NumberFontChoice(rawValue: numberFontRaw) ?? .rounded
        return NumberStyle(fontChoice: choice, colorCoded: colorCodedNumbers)
    }

    private func headerCell(_ text: String, value: Int? = nil) -> some View {
        let color = value.flatMap { numberStyle.color(for: $0) } ?? .primary
        return Text(text)
            .font(numberStyle.font(size: 12, weight: .semibold))
            .frame(width: 58, height: 44)
            .foregroundColor(color)
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var valuesX: [Int] {
        normalizedRange(minValue: probabilityMinX, maxValue: probabilityMaxX)
    }

    private var valuesY: [Int] {
        normalizedRange(minValue: probabilityMinY, maxValue: probabilityMaxY)
    }

    private func normalizedRange(minValue: Int, maxValue: Int) -> [Int] {
        let lower = min(max(minValue, 0), 12)
        let upper = min(max(maxValue, 0), 12)
        if lower <= upper {
            return Array(lower...upper)
        }
        return Array(upper...lower)
    }

    private func probabilityLabel(threshold: Int, trials: Int) -> String {
        if threshold > trials {
            return "∅"
        }
        let fraction = Probability.atLeastSuccesses(
            trials: trials,
            successesAtLeast: threshold,
            successOutcomes: successOutcomes,
            totalOutcomes: totalOutcomes
        )
        switch format {
        case .fraction:
            return fraction.formatted
        case .decimal:
            return String(format: "%.4f", fraction.value)
        }
    }
}

struct ProbabilityGridCell: View {
    let label: String
    let numberStyle: NumberStyle
    let isDisabled: Bool

    var body: some View {
        Text(label)
            .font(numberStyle.font(size: fontSize(for: label), weight: .semibold))
            .foregroundColor(isDisabled ? .secondary : .primary)
            .frame(width: 58, height: 44)
            .minimumScaleFactor(0.6)
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func fontSize(for label: String) -> CGFloat {
        if label.count <= 6 {
            return 12
        }
        if label.count <= 8 {
            return 11
        }
        return 10
    }
}

struct ProbabilityCellData: Identifiable {
    let threshold: Int
    let trials: Int
    let successName: String
    let trialsName: String
    let successOutcomes: Int
    let totalOutcomes: Int

    var id: String { "\(threshold)-\(trials)-\(successOutcomes)-\(totalOutcomes)" }
}

struct ProbabilityExplanationSheet: View {
    let cell: ProbabilityCellData
    let rowValues: [Int]
    let columnValues: [Int]
    let format: ProbabilityFormat
    let numberStyle: NumberStyle
    let onNavigate: (Int, Int) -> Void

    private var fraction: Fraction {
        Probability.atLeastSuccesses(
            trials: cell.trials,
            successesAtLeast: cell.threshold,
            successOutcomes: cell.successOutcomes,
            totalOutcomes: cell.totalOutcomes
        )
    }

    private var denominator: String {
        NumberFormatting.string(from: fraction.denominator)
    }

    private var numerator: String {
        NumberFormatting.string(from: fraction.numerator)
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("At least \(NumberFormatting.string(from: cell.threshold)) \(successLabel) after \(NumberFormatting.string(from: cell.trials)) \(trialsLabel)")
                        .font(numberStyle.font(size: 22, weight: .semibold))
                        .padding(.top, 12)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Success rate")
                            .font(.headline)
                        Text("\(NumberFormatting.string(from: cell.successOutcomes))/\(NumberFormatting.string(from: cell.totalOutcomes)) per \(singularTrialsName)")
                            .font(numberStyle.font(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Exact fraction")
                            .font(.headline)
                        Text("\(numerator)/\(denominator)")
                            .font(numberStyle.font(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Formula")
                            .font(.headline)
                        Text(formulaLine)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Text("k = \(NumberFormatting.string(from: cell.threshold)) ... \(NumberFormatting.string(from: cell.trials))")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        if let expandedLine {
                            Text(expandedLine)
                                .font(.footnote)
                                .foregroundColor(.accentColor)
                        }
                        if let resolvedLine {
                            Text(resolvedLine)
                                .font(.footnote)
                                .foregroundColor(.accentColor)
                        }
                        Text(denominatorLine)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Text("Numerator = \(numerator)")
                            .font(numberStyle.font(size: 16, weight: .semibold))
                            .foregroundColor(.accentColor)
                        Text("Denominator = \(denominator)")
                            .font(numberStyle.font(size: 16, weight: .semibold))
                            .foregroundColor(.accentColor)
                        if let exampleLine {
                            Text(exampleLine)
                                .font(.footnote)
                                .foregroundColor(.accentColor)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Decimal")
                            .font(.headline)
                        Text(decimalString)
                            .font(numberStyle.font(size: 18, weight: .semibold))
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Approximation")
                            .font(.headline)
                        Text("≈ \(approximationText)")
                            .font(numberStyle.font(size: 18, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            ProbabilityExplanationArrows(
                threshold: cell.threshold,
                trials: cell.trials,
                rowValues: rowValues,
                columnValues: columnValues,
                onNavigate: onNavigate
            )
        }
    }

    private var decimalString: String {
        switch format {
        case .fraction:
            return String(format: "%.6f", fraction.value)
        case .decimal:
            return String(format: "%.6f", fraction.value)
        }
    }

    private var failureOutcomes: Int {
        max(cell.totalOutcomes - cell.successOutcomes, 0)
    }

    private var singularTrialsName: String {
        if cell.trialsName.hasSuffix("s") {
            return String(cell.trialsName.dropLast())
        }
        return cell.trialsName
    }

    private var successLabel: String {
        if cell.threshold == 1 {
            return singularSuccessName
        }
        return cell.successName
    }

    private var trialsLabel: String {
        if cell.trials == 1 {
            return singularTrialsName
        }
        return cell.trialsName
    }

    private var singularSuccessName: String {
        let lower = cell.successName.lowercased()
        let mapped: [String: String] = [
            "sixes": "six",
            "aces": "ace",
            "spades": "spade",
            "heads": "head",
            "black cards": "black card"
        ]
        if let match = mapped[lower] {
            return match
        }
        if lower.hasSuffix("s") {
            return String(cell.successName.dropLast())
        }
        return cell.successName
    }

    private var formulaLine: AttributedString {
        var result = AttributedString("∑ C(\(NumberFormatting.string(from: cell.trials)), k) × ")
        result.append(exponent(base: cell.successOutcomes, power: "k"))
        result.append(AttributedString(" × "))
        result.append(exponent(base: failureOutcomes, power: "\(NumberFormatting.string(from: cell.trials))−k"))
        return result
    }

    private var denominatorLine: AttributedString {
        var result = AttributedString("Divide by ")
        result.append(exponent(base: cell.totalOutcomes, power: NumberFormatting.string(from: cell.trials)))
        return result
    }

    private func exponent(base: Int, power: String) -> AttributedString {
        var result = AttributedString(NumberFormatting.string(from: base))
        var powerText = AttributedString(power)
        powerText.font = .system(size: 11, weight: .semibold)
        powerText.baselineOffset = 6
        result.append(powerText)
        return result
    }

    private var approximationText: String {
        let approximation = approximateFraction(value: fraction.value)
        let numerator = NumberFormatting.string(from: approximation.numerator)
        let denominator = NumberFormatting.string(from: approximation.denominator)
        return "\(numerator)/\(denominator)"
    }

    private var expandedLine: AttributedString? {
        guard cell.threshold <= cell.trials else { return nil }
        var result = AttributedString("")
        var isFirst = true
        for k in cell.threshold...cell.trials {
            if !isFirst {
                result.append(AttributedString(" + "))
            }
            isFirst = false
            result.append(AttributedString("C(\(NumberFormatting.string(from: cell.trials)), \(NumberFormatting.string(from: k))) × "))
            result.append(exponent(base: cell.successOutcomes, power: NumberFormatting.string(from: k)))
            result.append(AttributedString(" × "))
            result.append(exponent(base: failureOutcomes, power: NumberFormatting.string(from: cell.trials - k)))
        }
        return result
    }

    private var resolvedLine: String? {
        guard cell.threshold <= cell.trials else { return nil }
        var parts: [String] = []
        for k in cell.threshold...cell.trials {
            let chooseValue = Combinatorics.choose(n: cell.trials, k: k)
            let successPower = decimalPow(base: cell.successOutcomes, exponent: k)
            let failurePower = decimalPow(base: failureOutcomes, exponent: cell.trials - k)
            let chooseString = NumberFormatting.string(from: chooseValue)
            let successString = NumberFormatting.string(from: successPower)
            let failureString = NumberFormatting.string(from: failurePower)
            parts.append("\(chooseString) × \(successString) × \(failureString)")
        }
        return parts.joined(separator: " + ")
    }

    private var exampleLine: AttributedString? {
        guard cell.threshold <= cell.trials else { return nil }
        let k = cell.threshold
        var result = AttributedString("Example (k = \(NumberFormatting.string(from: k))): ")
        result.append(exponent(base: cell.successOutcomes, power: NumberFormatting.string(from: k)))
        result.append(AttributedString(" × "))
        result.append(exponent(base: failureOutcomes, power: NumberFormatting.string(from: cell.trials - k)))
        return result
    }

    private func decimalPow(base: Int, exponent: Int) -> Decimal {
        guard exponent > 0 else { return exponent == 0 ? 1 : 0 }
        var result = Decimal(1)
        let baseDecimal = Decimal(base)
        for _ in 0..<exponent {
            result *= baseDecimal
        }
        return result
    }

    private func approximateFraction(value: Double) -> (numerator: Int, denominator: Int) {
        guard value > 0 else { return (0, 1) }
        guard value < 1 else { return (1, 1) }

        let unitDenominator = max(1, Int(round(1.0 / value)))
        let unitValue = 1.0 / Double(unitDenominator)
        let complementDenominator = max(1, Int(round(1.0 / (1.0 - value))))
        let complementValue = 1.0 - 1.0 / Double(complementDenominator)

        let unitError = abs(unitValue - value)
        let complementError = abs(complementValue - value)

        if complementError < unitError {
            return (max(complementDenominator - 1, 0), complementDenominator)
        }
        return (1, unitDenominator)
    }
}
