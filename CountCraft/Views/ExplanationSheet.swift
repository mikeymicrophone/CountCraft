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

struct ExponentExplanationView: View {
    let base: Int
    let exponent: Int
    let color: Color
    let numberFont: (CGFloat, Font.Weight) -> Font

    @State private var currentStep: Int = 1

    private var maxStep: Int {
        max(exponent, 1)
    }

    private func valueAtStep(_ step: Int) -> Int {
        Int(pow(Double(base), Double(step)))
    }

    private func labelForStep(_ step: Int) -> String {
        if step == 1 {
            return "\(base)"
        } else {
            let previousValue = valueAtStep(step - 1)
            let currentValue = valueAtStep(step)
            return "\(base) groups of \(previousValue) = \(currentValue)"
        }
    }

    private func groupCountAtStep(_ step: Int) -> Int {
        if step == 1 {
            return 1
        } else {
            return base
        }
    }

    private func squaresPerGroupAtStep(_ step: Int) -> Int {
        if step == 1 {
            return base
        } else {
            return valueAtStep(step - 1)
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Step label
            Text(labelForStep(currentStep))
                .font(numberFont(18, .semibold))
                .animation(.none, value: currentStep)

            // Segmented picker for steps
            Picker("Step", selection: $currentStep) {
                ForEach(1...maxStep, id: \.self) { step in
                    Text("\(base)\(superscript(step))").tag(step)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            // Visualization
            GroupedSquaresView(
                groupCount: groupCountAtStep(currentStep),
                squaresPerGroup: squaresPerGroupAtStep(currentStep),
                base: base,
                color: color
            )
            .frame(maxWidth: .infinity, minHeight: 200)
            .animation(.easeInOut(duration: 0.3), value: currentStep)
            .padding(.bottom, 30)
        }
    }

    private func superscript(_ n: Int) -> String {
        let superscripts = ["⁰", "¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹"]
        if n < 10 {
            return superscripts[n]
        }
        return String(n).map { superscripts[Int(String($0))!] }.joined()
    }
}

struct GroupedSquaresView: View {
    let groupCount: Int
    let squaresPerGroup: Int
    let base: Int
    let color: Color

    private var totalSquares: Int {
        groupCount * squaresPerGroup
    }

    private var columns: Int {
        // For nested groups, use base as column count within each group
        min(base, 6)
    }

    private func squareSizeFor(total: Int, availableWidth: CGFloat, availableHeight: CGFloat) -> CGFloat {
        // Calculate appropriate square size based on total count
        let maxSize: CGFloat = 24
        let minSize: CGFloat = 4

        if total <= 16 {
            return maxSize
        } else if total <= 64 {
            return 18
        } else if total <= 256 {
            return 12
        } else if total <= 1024 {
            return 8
        } else {
            return minSize
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let squareSize = squareSizeFor(total: totalSquares, availableWidth: proxy.size.width, availableHeight: proxy.size.height)
            let groupSpacing: CGFloat = squareSize > 10 ? 12 : 6
            let innerSpacing: CGFloat = max(2, squareSize * 0.15)

            let groupColumns = adaptiveGroupColumns(
                groupCount: groupCount,
                squaresPerGroup: squaresPerGroup,
                squareSize: squareSize,
                groupSpacing: groupSpacing,
                innerSpacing: innerSpacing,
                availableWidth: proxy.size.width
            )

            ScrollView {
                LazyVGrid(columns: groupColumns, spacing: groupSpacing) {
                    ForEach(0..<groupCount, id: \.self) { groupIndex in
                        SingleGroupView(
                            squareCount: squaresPerGroup,
                            columns: columns,
                            squareSize: squareSize,
                            spacing: innerSpacing,
                            color: color,
                            showBorder: groupCount > 1
                        )
                        .padding(.top, groupIndex % 2 == 1 && groupCount > 1 ? groupSpacing : 0)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func adaptiveGroupColumns(
        groupCount: Int,
        squaresPerGroup: Int,
        squareSize: CGFloat,
        groupSpacing: CGFloat,
        innerSpacing: CGFloat,
        availableWidth: CGFloat
    ) -> [GridItem] {
        let cols = min(squaresPerGroup, columns)
        let groupWidth = CGFloat(cols) * squareSize + CGFloat(cols - 1) * innerSpacing + 16
        let maxGroupsPerRow = max(1, Int((availableWidth + groupSpacing) / (groupWidth + groupSpacing)))
        let groupsPerRow = min(groupCount, maxGroupsPerRow)

        return Array(repeating: GridItem(.flexible(), spacing: groupSpacing), count: groupsPerRow)
    }
}

struct SingleGroupView: View {
    let squareCount: Int
    let columns: Int
    let squareSize: CGFloat
    let spacing: CGFloat
    let color: Color
    let showBorder: Bool

    private var rows: Int {
        max(1, Int(ceil(Double(squareCount) / Double(columns))))
    }

    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.fixed(squareSize), spacing: spacing), count: columns),
            spacing: spacing
        ) {
            ForEach(0..<squareCount, id: \.self) { _ in
                RoundedRectangle(cornerRadius: max(2, squareSize * 0.12))
                    .fill(color.opacity(0.85))
                    .frame(width: squareSize, height: squareSize)
            }
        }
        .padding(showBorder ? 8 : 0)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(showBorder ? 0.3 : 0), lineWidth: 2)
        )
    }
}
