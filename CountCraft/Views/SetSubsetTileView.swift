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
        Text(setText)
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

    private var setText: AttributedString {
        var result = AttributedString()
        var open = AttributedString("{")
        open.foregroundColor = .secondary
        result.append(open)

        if !values.isEmpty {
            for (index, value) in values.enumerated() {
                if index > 0 {
                    var comma = AttributedString(", ")
                    comma.foregroundColor = .secondary
                    result.append(comma)
                }
                let valueText = numberStyle.attributedNumber(
                    NumberFormatting.string(from: value),
                    value: value
                )
                result.append(valueText)
            }
        }

        var close = AttributedString("}")
        close.foregroundColor = .secondary
        result.append(close)
        return result
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
