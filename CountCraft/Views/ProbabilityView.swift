//
//  ProbabilityView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import SwiftUI

struct ProbabilityView: View {
    @State private var mode: ProbabilityMode = .dice
    @State private var format: ProbabilityFormat = .fraction

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker("Mode", selection: $mode) {
                    ForEach(ProbabilityMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Format", selection: $format) {
                    ForEach(ProbabilityFormat.allCases) { format in
                        Text(format.title).tag(format)
                    }
                }
                .pickerStyle(.segmented)

                Divider()

                switch mode {
                case .dice:
                    ProbabilityGridView(
                        title: "At least x sixes after y rolls",
                        rowLabel: "Rows: x (sixes). Columns: y (rolls).",
                        successOutcomes: 1,
                        totalOutcomes: 6,
                        format: format
                    )
                case .coin:
                    ProbabilityGridView(
                        title: "At least x heads after y flips",
                        rowLabel: "Rows: x (heads). Columns: y (flips).",
                        successOutcomes: 1,
                        totalOutcomes: 2,
                        format: format
                    )
                case .cards:
                    placeholder("Card outcomes are coming next.")
                }

                Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle("Probability")
        }
    }

    private func placeholder(_ message: String) -> some View {
        Text(message)
            .font(.headline)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

private enum ProbabilityMode: String, CaseIterable, Identifiable {
    case coin
    case dice
    case cards

    var id: String { rawValue }

    var title: String {
        switch self {
        case .coin:
            return "Coin"
        case .dice:
            return "Dice"
        case .cards:
            return "Cards"
        }
    }
}

private enum ProbabilityFormat: String, CaseIterable, Identifiable {
    case fraction
    case decimal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fraction:
            return "Fraction"
        case .decimal:
            return "Decimal"
        }
    }
}

private struct ProbabilityGridView: View {
    let title: String
    let rowLabel: String
    let successOutcomes: Int
    let totalOutcomes: Int
    let format: ProbabilityFormat
    @AppStorage("prefColorCodedNumbers") private var colorCodedNumbers = false
    @AppStorage("prefNumberFont") private var numberFontRaw = NumberFontChoice.rounded.rawValue

    private let range = 0...12

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
                                    label: probabilityLabel(threshold: threshold, throws: throwCount),
                                    numberStyle: numberStyle
                                )
                            }
                        }
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

    private func probabilityLabel(threshold: Int, throws throwCount: Int) -> String {
        if threshold > throwCount {
            return "∅"
        }
            let fraction = Probability.atLeastSuccesses(
                trials: throwCount,
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

private struct ProbabilityGridCell: View {
    let label: String
    let numberStyle: NumberStyle

    var body: some View {
        Text(label)
            .font(numberStyle.font(size: fontSize(for: label), weight: .semibold))
            .foregroundColor(.primary)
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
