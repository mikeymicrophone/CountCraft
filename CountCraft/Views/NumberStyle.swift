//
//  NumberStyle.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import SwiftUI

struct NumberStyle {
    let fontChoice: NumberFontChoice
    let colorCoded: Bool

    func font(size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        fontChoice.font(size: size, weight: weight)
    }

    func color(for value: Int) -> Color? {
        NumberStyling.color(for: value, enabled: colorCoded)
    }

    func primaryColor(for value: Int) -> Color {
        color(for: value) ?? .primary
    }

    func secondaryColor(for value: Int) -> Color {
        color(for: value) ?? .secondary
    }
}
