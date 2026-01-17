//
//  ExplanationSheet.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import SwiftUI

struct ExplanationSheet: View {
    let operation: OperationType
    let fact: MathFact
    let rowValues: [Int]
    let columnValues: [Int]
    let onNavigate: (MathFact) -> Void
    let onSwitchOperation: ((OperationType) -> Void)?

    @AppStorage("prefColorCodedNumbers") private var colorCodedNumbers = false
    @AppStorage("prefNumberFont") private var numberFontRaw = NumberFontChoice.rounded.rawValue

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ExplanationHeaderView(
                    operation: operation,
                    fact: fact,
                    numberStyle: numberStyle
                )
                ZStack {
                    explanationContent
                        .frame(maxWidth: operation == .exponent ? .infinity : 520)
                        .padding(.horizontal, operation == .exponent ? 16 : 24)
                        .padding(.top, operation == .exponent ? 48 : 28)
                    ExplanationNavigationArrows(
                        operation: operation,
                        fact: fact,
                        rowValues: rowValues,
                        columnValues: columnValues,
                        onNavigate: onNavigate,
                        onSwitchOperation: onSwitchOperation
                    )
                }
                .frame(maxWidth: .infinity, minHeight: operation == .exponent ? 320 : 280)
            }
            .padding()
        }
    }

    private var additionExplanation: some View {
        HStack(alignment: .top, spacing: 16) {
            bankColumn(label: NumberFormatting.string(from: fact.a), value: fact.a)
            Text("+")
                .font(numberStyle.font(size: 24, weight: .semibold))
                .foregroundColor(.secondary)
            bankColumn(label: NumberFormatting.string(from: fact.b), value: fact.b)
        }
        .frame(maxWidth: .infinity)
    }

    private var exponentExplanation: some View {
        ExponentExplanationView(
            base: fact.a,
            exponent: fact.b,
            color: numberStyle.color(for: fact.a) ?? .blue,
            numberStyle: numberStyle
        )
    }

    private func gridColumns(for value: Int) -> Int {
        max(min(value, 6), 1)
    }

    private var explanationContent: some View {
        switch operation {
        case .addition:
            return AnyView(additionExplanation)
        case .multiplication:
            return AnyView(multiplicationExplanation)
        case .exponent:
            return AnyView(exponentExplanation)
        }
    }

    private var multiplicationExplanation: some View {
        VStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(NumberFormatting.string(from: fact.a)) Groups of \(NumberFormatting.string(from: fact.b))")
                    .font(numberStyle.font(size: 18, weight: .semibold))
                LazyVGrid(columns: bankColumns, spacing: 10) {
                    ForEach(0..<max(fact.a, 1), id: \.self) { index in
                        FitSquareGrid(
                            count: fact.b,
                            columns: gridColumns(for: fact.b),
                            color: numberStyle.secondaryColor(for: fact.b),
                            spacing: 4
                        )
                        .frame(width: 80, height: 80)
                        .padding(.vertical, 4)
                        .padding(.top, index % 2 == 1 ? 16 : 0)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Grid \(NumberFormatting.string(from: fact.a)) × \(NumberFormatting.string(from: fact.b))")
                    .font(numberStyle.font(size: 18, weight: .semibold))
                FitSquareGrid(
                    count: fact.a * fact.b,
                    columns: max(fact.b, 1),
                    color: numberStyle.secondaryColor(for: fact.a),
                    spacing: 3
                )
                .frame(maxWidth: 260, minHeight: 160)
            }
            .padding(.bottom, 30)
        }
    }

    private func bankColumn(label: String, value: Int) -> some View {
        VStack(spacing: 8) {
            Text(label)
                .font(numberStyle.font(size: 18, weight: .semibold))
                .foregroundColor(numberStyle.primaryColor(for: value))
            FitSquareGrid(
                count: value,
                columns: gridColumns(for: value),
                color: numberStyle.secondaryColor(for: value),
                spacing: 4
            )
            .frame(width: 100, height: 100)
        }
    }

    private var bankColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 70), spacing: 16)]
    }

    private var numberFontChoice: NumberFontChoice {
        NumberFontChoice(rawValue: numberFontRaw) ?? .rounded
    }

    private var numberStyle: NumberStyle {
        NumberStyle(fontChoice: numberFontChoice, colorCoded: colorCodedNumbers)
    }
}
