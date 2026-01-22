//
//  NumberStyling.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import SwiftUI

struct NumberStyling {
    static let palette: [Color] = [
        .red, .orange, .yellow, .green, .mint, .pink, .cyan,
        .blue, .indigo, .purple, .teal, .brown, .gray
    ]

    static func color(for value: Int, enabled: Bool) -> Color? {
        guard enabled else { return nil }
        let absolute = abs(value)
        if absolute < 10 {
            return palette[absolute % palette.count]
        }
        let onesDigit = absolute % 10
        return palette[onesDigit % palette.count]
    }

    static func borderColor(for value: Int, enabled: Bool) -> Color? {
        guard enabled else { return nil }
        let absolute = abs(value)
        guard absolute >= 10 else { return nil }
        let tensDigit = (absolute / 10) % 10
        return palette[tensDigit % palette.count]
    }
}
