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
        guard enabled, (0...12).contains(value) else { return nil }
        return palette[value % palette.count]
    }
}
