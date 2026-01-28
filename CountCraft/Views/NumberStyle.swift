//
//  NumberStyle.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import SwiftUI
import UIKit

struct NumberStyle: Equatable {
    let fontChoice: NumberFontChoice
    let colorCoded: Bool

    enum Role {
        case primary
        case secondary
    }

    private static let innerOutlineRadius = 1
    private static let outerOutlineRadius = 2
    private static let outerStrokeAlpha: CGFloat = 0.95
    private static let innerOffsets = outlineOffsets(radius: innerOutlineRadius)
    private static let outerOffsets = outlineOffsets(radius: outerOutlineRadius)

    func font(size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        fontChoice.font(size: size, weight: weight)
    }

    func color(for value: Int) -> Color? {
        NumberStyling.color(for: value, enabled: colorCoded)
    }

    func borderColor(for value: Int) -> Color? {
        NumberStyling.borderColor(for: value, enabled: colorCoded)
    }

    @ViewBuilder
    func outlinedNumberText(_ value: Int, role: Role = .primary) -> some View {
        outlinedNumberText(NumberFormatting.string(from: value), value: value, role: role)
    }

    @ViewBuilder
    func outlinedNumberText(_ text: String, value: Int, role: Role = .primary) -> some View {
        let fill = fillAttributedString(text, value: value, role: role)
        let innerOutline = innerOutlineAttributedString(text, value: value, role: role)
        let outerOutline = outerOutlineAttributedString(text, value: value, role: role)
        outlinedAttributedText(fill: fill, innerOutline: innerOutline, outerOutline: outerOutline)
    }

    @ViewBuilder
    func outlinedAttributedText(
        fill: AttributedString,
        innerOutline: AttributedString?,
        outerOutline: AttributedString?
    ) -> some View {
        Text(fill)
            .background(outlineLayer(outerOutline, offsets: Self.outerOffsets))
            .background(outlineLayer(innerOutline, offsets: Self.innerOffsets))
    }

    func primaryColor(for value: Int) -> Color {
        color(for: value) ?? .primary
    }

    func secondaryColor(for value: Int) -> Color {
        color(for: value) ?? .secondary
    }

    func fillAttributedString(_ text: String, value: Int, role: Role = .primary) -> AttributedString {
        let fallback: Color = role == .primary ? .primary : .secondary
        let fill = color(for: value) ?? fallback
        var attributed = AttributedString(text)
        attributed.foregroundColor = fill
        return attributed
    }

    func innerOutlineAttributedString(
        _ text: String,
        value: Int,
        role: Role = .primary
    ) -> AttributedString? {
        outlineAttributedString(
            text,
            value: value,
            role: role,
            alpha: 1
        )
    }

    func outerOutlineAttributedString(
        _ text: String,
        value: Int,
        role: Role = .primary
    ) -> AttributedString? {
        outlineAttributedString(
            text,
            value: value,
            role: role,
            alpha: Self.outerStrokeAlpha
        )
    }

    private func outlineAttributedString(
        _ text: String,
        value: Int,
        role: Role,
        alpha: CGFloat
    ) -> AttributedString? {
        guard abs(value) < 100 else { return nil }
        guard let stroke = borderColor(for: value) else { return nil }
        let strokeUIColor = UIColor(stroke).withAlphaComponent(alpha)
        var attributed = AttributedString(text)
        attributed.foregroundColor = Color(strokeUIColor)
        return attributed
    }

    @ViewBuilder
    private func outlineLayer(_ outline: AttributedString?, offsets: [CGSize]) -> some View {
        if let outline {
            ZStack {
                ForEach(offsets.indices, id: \.self) { index in
                    let offset = offsets[index]
                    Text(outline)
                        .offset(x: offset.width, y: offset.height)
                }
            }
        }
    }

    private static func outlineOffsets(radius: Int) -> [CGSize] {
        guard radius > 0 else { return [] }
        var offsets: [CGSize] = []
        for dx in -radius...radius {
            for dy in -radius...radius {
                if dx == 0 && dy == 0 { continue }
                if max(abs(dx), abs(dy)) == radius {
                    offsets.append(CGSize(width: CGFloat(dx), height: CGFloat(dy)))
                }
            }
        }
        return offsets
    }

}

extension View {
    @ViewBuilder
    func numberBorder(_ color: Color?, cornerRadius: CGFloat, lineWidth: CGFloat = 2) -> some View {
        if let color {
            overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color, lineWidth: lineWidth)
            )
        } else {
            self
        }
    }
}
