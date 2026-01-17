//
//  ProbabilityGridView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import SwiftUI

struct ProbabilityGridView: View {
    let title: String
    let rowLabel: String
    let successName: String
    let trialsName: String
    let successOutcomes: Int
    let totalOutcomes: Int
    let format: ProbabilityFormat
    @AppStorage("prefColorCodedNumbers") private var colorCodedNumbers = false
    @AppStorage("prefNumberFont") private var numberFontRaw = NumberFontChoice.rounded.rawValue

    private let range = 0...12
    @State private var activeCell: ProbabilityCellData?

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(rowLabel)
                .font(.footnote)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView([.horizontal, .vertical]) {
                LazyVStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        headerCell("x/y")
                        ForEach(range, id: \.self) { value in
                            headerCell(NumberFormatting.string(from: value), value: value)
                        }
                    }

                    ForEach(range, id: \.self) { threshold in
                        HStack(spacing: 8) {
                            headerCell(">= \(NumberFormatting.string(from: threshold))", value: threshold)
                            ForEach(range, id: \.self) { throwCount in
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
            ProbabilityExplanationSheet(cell: cell, format: format, numberStyle: numberStyle)
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
    let format: ProbabilityFormat
    let numberStyle: NumberStyle

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
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("At least \(NumberFormatting.string(from: cell.threshold)) \(cell.successName) after \(NumberFormatting.string(from: cell.trials)) \(cell.trialsName)")
                    .font(numberStyle.font(size: 22, weight: .semibold))

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
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Formula")
                        .font(.headline)
                    Text("∑ C(\(NumberFormatting.string(from: cell.trials)), k) × \(NumberFormatting.string(from: cell.successOutcomes))^k × \(NumberFormatting.string(from: failureOutcomes))^(\(NumberFormatting.string(from: cell.trials))−k)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Text("k = \(NumberFormatting.string(from: cell.threshold)) ... \(NumberFormatting.string(from: cell.trials))")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Text("Divide by \(NumberFormatting.string(from: cell.totalOutcomes))^\(NumberFormatting.string(from: cell.trials))")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Decimal")
                        .font(.headline)
                    Text(decimalString)
                        .font(numberStyle.font(size: 18, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
            .padding()
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
}
