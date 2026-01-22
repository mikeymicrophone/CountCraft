//
//  NumberStyle.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import SwiftUI
import UIKit

struct NumberStyle {
    let fontChoice: NumberFontChoice
    let colorCoded: Bool

    enum Role {
        case primary
        case secondary
    }

    func font(size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        fontChoice.font(size: size, weight: weight)
    }

    func color(for value: Int) -> Color? {
        NumberStyling.color(for: value, enabled: colorCoded)
    }

    func borderColor(for value: Int) -> Color? {
        NumberStyling.borderColor(for: value, enabled: colorCoded)
    }

    func attributedNumber(_ value: Int, role: Role = .primary) -> AttributedString {
        attributedNumber(NumberFormatting.string(from: value), value: value, role: role)
    }

    func attributedNumber(_ text: String, value: Int, role: Role = .primary) -> AttributedString {
        let fallback: Color = role == .primary ? .primary : .secondary
        let fill = color(for: value) ?? fallback
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(fill)
        ]
        if let stroke = borderColor(for: value) {
            attributes[.strokeColor] = UIColor(stroke)
            attributes[.strokeWidth] = -1
        }
        return AttributedString(NSAttributedString(string: text, attributes: attributes))
    }

    func primaryColor(for value: Int) -> Color {
        color(for: value) ?? .primary
    }

    func secondaryColor(for value: Int) -> Color {
        color(for: value) ?? .secondary
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
