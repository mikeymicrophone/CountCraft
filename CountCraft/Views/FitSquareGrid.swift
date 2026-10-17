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

private extension CGFloat {
    func rounded(toPlaces places: Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }
}
