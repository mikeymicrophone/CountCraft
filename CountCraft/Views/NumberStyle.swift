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
    private static let innerContrastBoost: CGFloat = 0.25
    private static let outerContrastBoost: CGFloat = 0.55
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
            boost: Self.innerContrastBoost,
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
            boost: Self.outerContrastBoost,
            alpha: Self.outerStrokeAlpha
        )
    }

    private func outlineAttributedString(
        _ text: String,
        value: Int,
        role: Role,
        boost: CGFloat,
        alpha: CGFloat
    ) -> AttributedString? {
        guard let stroke = borderColor(for: value) else { return nil }
        let fallback: Color = role == .primary ? .primary : .secondary
        let fillColor = color(for: value) ?? fallback
        let strokeUIColor = contrastedStrokeColor(
            UIColor(stroke),
            fill: UIColor(fillColor),
            boost: boost
        ).withAlphaComponent(alpha)
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

    private func contrastedStrokeColor(_ stroke: UIColor, fill: UIColor, boost: CGFloat) -> UIColor {
        let fillLuminance = fill.luminance()
        let delta = fillLuminance > 0.6 ? -boost : boost
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        if stroke.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            let newBrightness = min(max(brightness + delta, 0), 1)
            let newSaturation = min(max(saturation + boost * 0.4, 0), 1)
            return UIColor(hue: hue, saturation: newSaturation, brightness: newBrightness, alpha: alpha)
        }
        return stroke.adjustedBrightness(delta)
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

private extension UIColor {
    func luminance() -> CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return 0.2126 * red + 0.7152 * green + 0.0722 * blue
        }
        var white: CGFloat = 0
        if getWhite(&white, alpha: &alpha) {
            return white
        }
        return 0.5
    }

    func adjustedBrightness(_ delta: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            let newBrightness = min(max(brightness + delta, 0), 1)
            return UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
        }
        var white: CGFloat = 0
        if getWhite(&white, alpha: &alpha) {
            let newWhite = min(max(white + delta, 0), 1)
            return UIColor(white: newWhite, alpha: alpha)
        }
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(
                red: min(max(red + delta, 0), 1),
                green: min(max(green + delta, 0), 1),
                blue: min(max(blue + delta, 0), 1),
                alpha: alpha
            )
        }
        return self
    }
}
