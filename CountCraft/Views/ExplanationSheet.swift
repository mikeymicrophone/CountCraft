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

    @AppStorage("prefColorCodedNumbers") private var colorCodedNumbers = false
    @AppStorage("prefNumberFont") private var numberFontRaw = NumberFontChoice.rounded.rawValue

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView
                ZStack {
                    explanationContent
                        .frame(maxWidth: operation == .exponent ? .infinity : 520)
                        .padding(.horizontal, operation == .exponent ? 16 : 24)
                        .padding(.top, 18)
                    navigationArrows
                }
                .frame(maxWidth: .infinity, minHeight: operation == .exponent ? 360 : 280)
            }
            .padding()
        }
    }

    @ViewBuilder
    private var headerView: some View {
        if operation == .exponent {
            HStack(spacing: 6) {
                exponentSuperscriptText(
                    base: fact.a,
                    exponent: fact.b,
                    baseSize: 28,
                    exponentSize: 18,
                    exponentOffset: 12,
                    baseColor: numberColor(for: fact.a) ?? .primary,
                    exponentColor: numberColor(for: fact.b) ?? .primary
                )
                Text("=")
                    .foregroundColor(.secondary)
                    .font(numberFont(size: 28, weight: .semibold))
                Text(NumberFormatting.string(from: operation.answer(for: fact)))
                    .foregroundColor(numberColor(for: operation.answer(for: fact)) ?? .primary)
                    .font(numberFont(size: 28, weight: .semibold))
            }
        } else {
            HStack(spacing: 8) {
                Text(NumberFormatting.string(from: fact.a))
                    .foregroundColor(numberColor(for: fact.a) ?? .primary)
                Text(operation.symbol)
                    .foregroundColor(.secondary)
                Text(NumberFormatting.string(from: fact.b))
                    .foregroundColor(numberColor(for: fact.b) ?? .primary)
                Text("=")
                    .foregroundColor(.secondary)
                Text(NumberFormatting.string(from: operation.answer(for: fact)))
                    .foregroundColor(numberColor(for: operation.answer(for: fact)) ?? .primary)
            }
            .font(numberFont(size: 28, weight: .semibold))
        }
    }

    private func exponentSuperscriptText(
        base: Int,
        exponent: Int,
        baseSize: CGFloat,
        exponentSize: CGFloat,
        exponentOffset: CGFloat,
        baseColor: Color,
        exponentColor: Color
    ) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text(NumberFormatting.string(from: base))
                .foregroundColor(baseColor)
                .font(numberFont(size: baseSize, weight: .semibold))
            Text(NumberFormatting.string(from: exponent))
                .foregroundColor(exponentColor)
                .font(numberFont(size: exponentSize, weight: .semibold))
                .baselineOffset(exponentOffset)
        }
    }

    private var additionExplanation: some View {
        HStack(alignment: .top, spacing: 16) {
            bankColumn(label: NumberFormatting.string(from: fact.a), value: fact.a)
            Text("+")
                .font(numberFont(size: 24, weight: .semibold))
                .foregroundColor(.secondary)
            bankColumn(label: NumberFormatting.string(from: fact.b), value: fact.b)
        }
        .frame(maxWidth: .infinity)
    }

    private var exponentExplanation: some View {
        ExponentExplanationView(
            base: fact.a,
            exponent: fact.b,
            color: numberColor(for: fact.a) ?? .blue,
            numberFont: numberFont
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
                    .font(numberFont(size: 18, weight: .semibold))
                LazyVGrid(columns: bankColumns, spacing: 10) {
                    ForEach(0..<max(fact.a, 1), id: \.self) { index in
                        FitSquareGrid(
                            count: fact.b,
                            columns: gridColumns(for: fact.b),
                            color: numberColor(for: fact.b) ?? .secondary,
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
                    .font(numberFont(size: 18, weight: .semibold))
                FitSquareGrid(
                    count: fact.a * fact.b,
                    columns: max(fact.b, 1),
                    color: numberColor(for: fact.a) ?? .secondary,
                    spacing: 3
                )
                .frame(maxWidth: 260, minHeight: 160)
            }
            .padding(.bottom, 30)
        }
    }

    private var navigationArrows: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            ZStack {
                arrowButton(
                    systemName: "arrow.up",
                    enabled: canMove(rowDelta: -1, colDelta: 0)
                ) {
                    move(rowDelta: -1, colDelta: 0)
                }
                .position(x: width / 2, y: 8)

                arrowButton(
                    systemName: "arrow.down",
                    enabled: canMove(rowDelta: 1, colDelta: 0)
                ) {
                    move(rowDelta: 1, colDelta: 0)
                }
                .position(x: width / 2, y: height - 8)

                arrowButton(
                    systemName: "arrow.left",
                    enabled: canMove(rowDelta: 0, colDelta: -1)
                ) {
                    move(rowDelta: 0, colDelta: -1)
                }
                .position(x: 8, y: height / 2)

                arrowButton(
                    systemName: "arrow.right",
                    enabled: canMove(rowDelta: 0, colDelta: 1)
                ) {
                    move(rowDelta: 0, colDelta: 1)
                }
                .position(x: width - 8, y: height / 2)
            }
        }
    }

    private func arrowButton(
        systemName: String,
        enabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.headline)
                .foregroundColor(enabled ? .secondary : Color.secondary.opacity(0.35))
                .padding(8)
                .background(Color(.systemBackground))
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }

    private func bankColumn(label: String, value: Int) -> some View {
        VStack(spacing: 8) {
            Text(label)
                .font(numberFont(size: 18, weight: .semibold))
                .foregroundColor(numberColor(for: value) ?? .primary)
            FitSquareGrid(
                count: value,
                columns: gridColumns(for: value),
                color: numberColor(for: value) ?? .secondary,
                spacing: 4
            )
            .frame(width: 100, height: 100)
        }
    }

    private var bankColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 70), spacing: 16)]
    }

    private func canMove(rowDelta: Int, colDelta: Int) -> Bool {
        guard let rowIndex = rowValues.firstIndex(of: fact.a),
              let colIndex = columnValues.firstIndex(of: fact.b) else {
            return false
        }
        let targetRow = rowIndex + rowDelta
        let targetCol = colIndex + colDelta
        return rowValues.indices.contains(targetRow) && columnValues.indices.contains(targetCol)
    }

    private func move(rowDelta: Int, colDelta: Int) {
        guard let rowIndex = rowValues.firstIndex(of: fact.a),
              let colIndex = columnValues.firstIndex(of: fact.b) else {
            return
        }
        let targetRow = rowIndex + rowDelta
        let targetCol = colIndex + colDelta
        guard rowValues.indices.contains(targetRow), columnValues.indices.contains(targetCol) else { return }
        let next = MathFact(a: rowValues[targetRow], b: columnValues[targetCol])
        onNavigate(next)
    }

    private var numberFontChoice: NumberFontChoice {
        NumberFontChoice(rawValue: numberFontRaw) ?? .rounded
    }

    private func numberFont(size: CGFloat, weight: Font.Weight) -> Font {
        numberFontChoice.font(size: size, weight: weight)
    }

    private func numberColor(for value: Int) -> Color? {
        NumberStyling.color(for: value, enabled: colorCodedNumbers)
    }
}
