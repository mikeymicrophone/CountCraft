//
//  SetSubsetTileView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import SwiftUI

struct SetSubsetTileView: View {
    let values: [Int]
    let numberStyle: NumberStyle

    var body: some View {
        let layers = setTextLayers()
        Group {
            numberStyle.outlinedAttributedText(
                fill: layers.fill,
                innerOutline: layers.inner,
                outerOutline: layers.outer
            )
        }
        .font(numberStyle.font(size: tileFontSize, weight: .semibold))
        .multilineTextAlignment(.center)
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .frame(minWidth: 80)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var tileFontSize: CGFloat {
        if values.count <= 4 {
            return 16
        }
        if values.count <= 6 {
            return 14
        }
        return 12
    }

    private func setTextLayers() -> (fill: AttributedString, inner: AttributedString?, outer: AttributedString?) {
        var fill = AttributedString()
        var inner = AttributedString()
        var outer = AttributedString()
        var hasInner = false
        var hasOuter = false

        appendSymbol("{", fill: &fill, inner: &inner, outer: &outer)
        if !values.isEmpty {
            for (index, value) in values.enumerated() {
                if index > 0 {
                    appendSymbol(", ", fill: &fill, inner: &inner, outer: &outer)
                }
                let text = NumberFormatting.string(from: value)
                fill.append(numberStyle.fillAttributedString(text, value: value))
                if let innerSegment = numberStyle.innerOutlineAttributedString(text, value: value) {
                    inner.append(innerSegment)
                    hasInner = true
                } else {
                    appendClear(text, to: &inner)
                }
                if let outerSegment = numberStyle.outerOutlineAttributedString(text, value: value) {
                    outer.append(outerSegment)
                    hasOuter = true
                } else {
                    appendClear(text, to: &outer)
                }
            }
        }
        appendSymbol("}", fill: &fill, inner: &inner, outer: &outer)

        return (
            fill: fill,
            inner: hasInner ? inner : nil,
            outer: hasOuter ? outer : nil
        )
    }

    private func appendSymbol(
        _ text: String,
        fill: inout AttributedString,
        inner: inout AttributedString,
        outer: inout AttributedString
    ) {
        var symbol = AttributedString(text)
        symbol.foregroundColor = .secondary
        fill.append(symbol)
        appendClear(text, to: &inner)
        appendClear(text, to: &outer)
    }

    private func appendClear(_ text: String, to attributed: inout AttributedString) {
        var clear = AttributedString(text)
        clear.foregroundColor = .clear
        attributed.append(clear)
    }
}

struct SetRemainingTileView: View {
    let remainingCount: Int
    let numberStyle: NumberStyle

    var body: some View {
        Text("+\(NumberFormatting.string(from: remainingCount))")
            .font(numberStyle.font(size: 16, weight: .semibold))
            .foregroundColor(.secondary)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .frame(minWidth: 80)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
