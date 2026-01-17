//
//  ExplanationSheet.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import SwiftUI
import UIKit
import SceneKit

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
    var maxRenderCells: Int = 4000
    @State private var cachedImage: UIImage?

    var body: some View {
        if count <= 0 {
            Text("0")
                .font(.footnote)
                .foregroundColor(.secondary)
        } else {
            GeometryReader { proxy in
                let groupSize = max(1, Int(ceil(Double(count) / Double(maxRenderCells))))
                let displayedCount = Int(ceil(Double(count) / Double(groupSize)))
                let cols = max(min(columns, displayedCount), 1)
                let rows = max(Int(ceil(Double(displayedCount) / Double(cols))), 1)
                let width = proxy.size.width
                let height = proxy.size.height
                let sizeByWidth = (width - CGFloat(cols - 1) * spacing) / CGFloat(cols)
                let sizeByHeight = (height - CGFloat(rows - 1) * spacing) / CGFloat(rows)
                let size = min(maxSize, max(minSize, min(sizeByWidth, sizeByHeight)))
                let renderKey = cacheKey(
                    size: proxy.size,
                    cellSize: size,
                    columns: cols,
                    displayedCount: displayedCount,
                    groupSize: groupSize
                )

                Group {
                    if let image = cachedImage ?? cachedImage(for: renderKey) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Color.clear
                    }
                }
                .frame(width: width, height: height, alignment: .center)
                .task(id: renderKey) {
                    cachedImage = renderImage(
                        size: proxy.size,
                        cellSize: size,
                        columns: cols,
                        displayedCount: displayedCount
                    )
                    if let cachedImage {
                        setCachedImage(cachedImage, for: renderKey)
                    }
                }
            }
        }
    }

    private func renderImage(
        size: CGSize,
        cellSize: CGFloat,
        columns: Int,
        displayedCount: Int
    ) -> UIImage? {
        guard size.width > 0, size.height > 0, cellSize > 0 else { return nil }
        let renderer = UIGraphicsImageRenderer(size: size)
        let uiColor = UIColor(color).withAlphaComponent(0.85)
        return renderer.image { context in
            context.cgContext.setFillColor(uiColor.cgColor)
            for index in 0..<displayedCount {
                let row = index / columns
                let col = index % columns
                let x = CGFloat(col) * (cellSize + spacing)
                let y = CGFloat(row) * (cellSize + spacing)
                let rect = CGRect(x: x, y: y, width: cellSize, height: cellSize)
                context.cgContext.fill(rect)
            }
        }
    }

    private func cacheKey(
        size: CGSize,
        cellSize: CGFloat,
        columns: Int,
        displayedCount: Int,
        groupSize: Int
    ) -> String {
        let colorKey = colorCacheKey()
        return "\(count)|\(displayedCount)|\(groupSize)|\(columns)|\(spacing)|\(cellSize)|\(size.width)x\(size.height)|\(colorKey)"
    }

    private func colorCacheKey() -> String {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return "\(red.rounded(toPlaces: 3))-\(green.rounded(toPlaces: 3))-\(blue.rounded(toPlaces: 3))-\(alpha.rounded(toPlaces: 3))"
    }

    private func cachedImage(for key: String) -> UIImage? {
        Self.cache.object(forKey: key as NSString)
    }

    private func setCachedImage(_ image: UIImage, for key: String) {
        Self.cache.setObject(image, forKey: key as NSString)
    }

    private static let cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 64
        return cache
    }()
}

private extension CGFloat {
    func rounded(toPlaces places: Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }
}

struct ExponentExplanationView: View {
    let base: Int
    let exponent: Int
    let color: Color
    let numberFont: (CGFloat, Font.Weight) -> Font

    @State private var currentStep: Int?
    @State private var isPlaying: Bool = false
    @State private var timer: Timer?

    private var step: Int {
        currentStep ?? exponent
    }

    private var maxStep: Int {
        min(max(exponent, 1), 3)
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

    private func startPlaying() {
        isPlaying = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            if step < maxStep {
                currentStep = step + 1
            } else {
                currentStep = 1
            }
        }
    }

    private func stopPlaying() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(labelForStep(step))
                .font(numberFont(18, .semibold))
                .animation(.none, value: step)

            HStack(spacing: 12) {
                Button {
                    if isPlaying {
                        stopPlaying()
                    } else {
                        startPlaying()
                    }
                } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.accentColor)
                        .frame(width: 32, height: 32)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Picker("Step", selection: Binding(
                    get: { step },
                    set: { currentStep = $0 }
                )) {
                    ForEach(1...maxStep, id: \.self) { s in
                        Text("\(base)\(superscript(s))").tag(s)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)

            ExponentSceneView(base: base, depth: step, color: color)
                .frame(maxWidth: .infinity, minHeight: 280)
                .animation(.easeInOut(duration: 0.2), value: step)
                .padding(.bottom, 30)
        }
        .onDisappear {
            stopPlaying()
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

struct ExponentRasterView: View {
    let base: Int
    let depth: Int
    let color: Color
    var maxRenderCells: Int = 200_000

    @State private var cachedImage: UIImage?

    var body: some View {
        GeometryReader { proxy in
            let renderKey = cacheKey(size: proxy.size)
            Group {
                if let image = cachedImage ?? cachedImage(for: renderKey) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    Color.clear
                }
            }
            .task(id: renderKey) {
                cachedImage = renderImage(size: proxy.size)
                if let cachedImage {
                    setCachedImage(cachedImage, for: renderKey)
                }
            }
        }
    }

    private func renderImage(size: CGSize) -> UIImage? {
        guard size.width > 0, size.height > 0 else { return nil }
        let renderer = UIGraphicsImageRenderer(size: size)
        let uiColor = UIColor(color).withAlphaComponent(0.85)
        return renderer.image { context in
            context.cgContext.setFillColor(uiColor.cgColor)
            let rect = CGRect(origin: .zero, size: size)
            drawRecursive(in: rect, depth: depth, context: context.cgContext)
        }
    }

    private func drawRecursive(in rect: CGRect, depth: Int, context: CGContext) {
        if depth <= 1 {
            drawBaseSquares(in: rect, context: context)
        } else if estimatedCellCount(depth: depth) > maxRenderCells {
            drawCompressedGrid(in: rect, context: context)
        } else {
            drawNestedGroups(in: rect, depth: depth, context: context)
        }
    }

    private func estimatedCellCount(depth: Int) -> Int {
        let value = pow(Double(base), Double(max(depth, 1)))
        if value > Double(Int.max) {
            return Int.max
        }
        return Int(value)
    }

    private func drawBaseSquares(in rect: CGRect, context: CGContext) {
        let count = max(base, 1)
        let spacingRatio: CGFloat = 0.06
        let totalSpacingRatio = spacingRatio * CGFloat(count - 1)
        let squareSize = min(rect.width / (CGFloat(count) + totalSpacingRatio * CGFloat(count)), rect.height)
        let spacing = squareSize * spacingRatio
        let totalWidth = CGFloat(count) * squareSize + spacing * CGFloat(count - 1)
        let startX = rect.midX - totalWidth / 2
        let startY = rect.midY - squareSize / 2

        for i in 0..<count {
            let x = startX + CGFloat(i) * (squareSize + spacing)
            let squareRect = CGRect(x: x, y: startY, width: squareSize, height: squareSize)
            context.fill(squareRect)
        }
    }

    private func drawNestedGroups(in rect: CGRect, depth: Int, context: CGContext) {
        let isVertical = depth % 2 == 0
        let spacingRatio: CGFloat = 0.04
        let count = max(base, 1)

        if isVertical {
            let spacing = rect.height * spacingRatio
            let groupHeight = (rect.height - spacing * CGFloat(count - 1)) / CGFloat(count)

            for i in 0..<count {
                let y = rect.minY + CGFloat(i) * (groupHeight + spacing)
                let groupRect = CGRect(x: rect.minX, y: y, width: rect.width, height: groupHeight)
                drawRecursive(in: groupRect, depth: depth - 1, context: context)
            }
        } else {
            let spacing = rect.width * spacingRatio
            let groupWidth = (rect.width - spacing * CGFloat(count - 1)) / CGFloat(count)

            for i in 0..<count {
                let x = rect.minX + CGFloat(i) * (groupWidth + spacing)
                let groupRect = CGRect(x: x, y: rect.minY, width: groupWidth, height: rect.height)
                drawRecursive(in: groupRect, depth: depth - 1, context: context)
            }
        }
    }

    private func drawCompressedGrid(in rect: CGRect, context: CGContext) {
        let total = max(estimatedCellCount(depth: depth), 1)
        let groupSize = max(1, Int(ceil(Double(total) / Double(maxRenderCells))))
        let displayed = Int(ceil(Double(total) / Double(groupSize)))
        let cols = max(Int(ceil(sqrt(Double(displayed)))), 1)
        let rows = max(Int(ceil(Double(displayed) / Double(cols))), 1)
        let spacingRatio: CGFloat = 0.04
        let spacing = min(rect.width, rect.height) * spacingRatio / CGFloat(max(cols, rows))
        let sizeByWidth = (rect.width - CGFloat(cols - 1) * spacing) / CGFloat(cols)
        let sizeByHeight = (rect.height - CGFloat(rows - 1) * spacing) / CGFloat(rows)
        let size = min(sizeByWidth, sizeByHeight)

        for index in 0..<displayed {
            let row = index / cols
            let col = index % cols
            let x = rect.minX + CGFloat(col) * (size + spacing)
            let y = rect.minY + CGFloat(row) * (size + spacing)
            context.fill(CGRect(x: x, y: y, width: size, height: size))
        }
    }

    private func cacheKey(size: CGSize) -> String {
        let colorKey = colorCacheKey()
        return "\(base)|\(depth)|\(size.width)x\(size.height)|\(maxRenderCells)|\(colorKey)"
    }

    private func colorCacheKey() -> String {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return "\(red.rounded(toPlaces: 3))-\(green.rounded(toPlaces: 3))-\(blue.rounded(toPlaces: 3))-\(alpha.rounded(toPlaces: 3))"
    }

    private func cachedImage(for key: String) -> UIImage? {
        Self.cache.object(forKey: key as NSString)
    }

    private func setCachedImage(_ image: UIImage, for key: String) {
        Self.cache.setObject(image, forKey: key as NSString)
    }

    private static let cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 32
        return cache
    }()
}

struct ExponentSceneView: View {
    let base: Int
    let depth: Int
    let color: Color

    var body: some View {
        SceneView(scene: scene, options: [.autoenablesDefaultLighting])
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var scene: SCNScene {
        let scene = SCNScene()
        let root = scene.rootNode
        let container = SCNNode()
        root.addChildNode(container)

        let cubeSize: CGFloat = 0.8
        let spacing: CGFloat = 0.22
        let step = cubeSize + spacing
        let extent = max(base, 1)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(color).withAlphaComponent(0.9)
        material.lightingModel = .lambert

        let box = SCNBox(width: cubeSize, height: cubeSize, length: cubeSize, chamferRadius: 0)
        box.materials = [material]

        let zRange = depth >= 3 ? 0..<extent : 0..<1
        let yRange = depth >= 2 ? 0..<extent : 0..<1
        let xRange = 0..<extent

        for z in zRange {
            for y in yRange {
                for x in xRange {
                    let node = SCNNode(geometry: box)
                    node.position = SCNVector3(
                        Float(CGFloat(x) * step),
                        Float(CGFloat(y) * step),
                        Float(CGFloat(z) * step)
                    )
                    container.addChildNode(node)
                }
            }
        }

        let bounds = container.boundingBox
        let minBounds = bounds.min
        let maxBounds = bounds.max
        let center = SCNVector3(
            (minBounds.x + maxBounds.x) / 2,
            (minBounds.y + maxBounds.y) / 2,
            (minBounds.z + maxBounds.z) / 2
        )
        container.position = SCNVector3(-center.x, -center.y, -center.z)

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 50
        let maxDimension = max(
            max(maxBounds.x - minBounds.x, maxBounds.y - minBounds.y),
            maxBounds.z - minBounds.z
        )
        cameraNode.position = SCNVector3(0, 0, Float(maxDimension * 2.4))
        root.addChildNode(cameraNode)

        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(Float(maxDimension), Float(maxDimension), Float(maxDimension))
        root.addChildNode(lightNode)

        if depth >= 3 {
            let rotate = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 16)
            container.runAction(SCNAction.repeatForever(rotate))
        } else {
            container.eulerAngles = SCNVector3(-0.35, 0.45, 0)
        }

        return scene
    }
}
