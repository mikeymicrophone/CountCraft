//
//  FitSquareGrid.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import SwiftUI
import UIKit

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

private extension CGFloat {
    func rounded(toPlaces places: Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }
}
