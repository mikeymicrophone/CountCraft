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
                    navigationArrows
                }
                .frame(maxWidth: .infinity, minHeight: operation == .exponent ? 360 : 280)
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

    var body: some View {
        VStack(spacing: 16) {
            Text(labelForStep(currentStep))
                .font(numberFont(18, .semibold))
                .animation(.none, value: currentStep)

            Picker("Step", selection: $currentStep) {
                ForEach(1...maxStep, id: \.self) { step in
                    Text("\(base)\(superscript(step))").tag(step)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            RecursiveExponentShape(base: base, depth: currentStep)
                .fill(color.opacity(0.85))
                .frame(maxWidth: .infinity, minHeight: 280)
                .animation(.easeInOut(duration: 0.4), value: currentStep)
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

struct RecursiveExponentShape: Shape {
    let base: Int
    var depth: Int

    var animatableData: Double {
        get { Double(depth) }
        set { depth = Int(newValue.rounded()) }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        drawRecursive(in: rect, depth: depth, path: &path)
        return path
    }

    private func drawRecursive(in rect: CGRect, depth: Int, path: inout Path) {
        if depth <= 1 {
            drawBaseSquares(in: rect, path: &path)
        } else {
            drawNestedGroups(in: rect, depth: depth, path: &path)
        }
    }

    private func drawBaseSquares(in rect: CGRect, path: inout Path) {
        // Depth 1 is always horizontal
        let count = base
        let spacingRatio: CGFloat = 0.06
        let totalSpacingRatio = spacingRatio * CGFloat(count - 1)
        let squareSize = min(rect.width / (CGFloat(count) + totalSpacingRatio * CGFloat(count)), rect.height)
        let spacing = squareSize * spacingRatio
        let totalWidth = CGFloat(count) * squareSize + spacing * CGFloat(count - 1)
        let startX = rect.midX - totalWidth / 2
        let startY = rect.midY - squareSize / 2
        let cornerRadius = squareSize * 0.15

        for i in 0..<count {
            let x = startX + CGFloat(i) * (squareSize + spacing)
            let squareRect = CGRect(x: x, y: startY, width: squareSize, height: squareSize)
            path.addRoundedRect(in: squareRect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
        }
    }

    private func drawNestedGroups(in rect: CGRect, depth: Int, path: inout Path) {
        // Alternate: even depth = vertical stacking, odd depth = horizontal stacking
        let isVertical = depth % 2 == 0
        let spacingRatio: CGFloat = 0.04

        if isVertical {
            // Stack groups vertically
            let spacing = rect.height * spacingRatio
            let groupHeight = (rect.height - spacing * CGFloat(base - 1)) / CGFloat(base)

            for i in 0..<base {
                let y = rect.minY + CGFloat(i) * (groupHeight + spacing)
                let groupRect = CGRect(x: rect.minX, y: y, width: rect.width, height: groupHeight)
                drawRecursive(in: groupRect, depth: depth - 1, path: &path)
            }
        } else {
            // Stack groups horizontally
            let spacing = rect.width * spacingRatio
            let groupWidth = (rect.width - spacing * CGFloat(base - 1)) / CGFloat(base)

            for i in 0..<base {
                let x = rect.minX + CGFloat(i) * (groupWidth + spacing)
                let groupRect = CGRect(x: x, y: rect.minY, width: groupWidth, height: rect.height)
                drawRecursive(in: groupRect, depth: depth - 1, path: &path)
            }
        }
    }
}
