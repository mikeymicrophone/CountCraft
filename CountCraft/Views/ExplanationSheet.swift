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
                        .frame(maxWidth: 520)
                        .padding(.horizontal, 24)
                    navigationArrows
                }
                .frame(maxWidth: .infinity, minHeight: 280)
            }
            .padding()
        }
    }

    private var headerView: some View {
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

    private var exponentPlaceholder: some View {
        VStack(spacing: 12) {
            Text("Exponent explanations are coming next.")
                .font(numberFont(size: 18, weight: .semibold))
            Text("I can show repeated multiplication, layered grids, or growth bars.")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
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
            return AnyView(exponentPlaceholder)
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

struct FitSquareGrid: View {
    let count: Int
    let columns: Int
    let color: Color
    var spacing: CGFloat = 4
    var minSize: CGFloat = 8
    var maxSize: CGFloat = 20

    var body: some View {
        if count <= 0 {
            Text("0")
                .font(.footnote)
                .foregroundColor(.secondary)
        } else {
            GeometryReader { proxy in
                let cols = max(columns, 1)
                let rows = max(Int(ceil(Double(count) / Double(cols))), 1)
                let width = proxy.size.width
                let height = proxy.size.height
                let sizeByWidth = (width - CGFloat(cols - 1) * spacing) / CGFloat(cols)
                let sizeByHeight = (height - CGFloat(rows - 1) * spacing) / CGFloat(rows)
                let size = min(maxSize, max(minSize, min(sizeByWidth, sizeByHeight)))

                LazyVGrid(columns: gridItems(size: size), spacing: spacing) {
                    ForEach(0..<count, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(color.opacity(0.85))
                            .frame(width: size, height: size)
                    }
                }
                .frame(width: width, height: height, alignment: .center)
            }
        }
    }

    private func gridItems(size: CGFloat) -> [GridItem] {
        Array(repeating: GridItem(.fixed(size), spacing: spacing), count: max(columns, 1))
    }
}
