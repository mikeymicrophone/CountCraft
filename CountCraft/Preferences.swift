//
//  Preferences.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import SwiftUI

enum NumberFontChoice: String, CaseIterable, Identifiable {
    case classic
    case rounded
    case serif
    case monospaced
    case italic

    var id: String { rawValue }

    var title: String {
        switch self {
        case .classic:
            return "Classic"
        case .rounded:
            return "Rounded"
        case .serif:
            return "Serif"
        case .monospaced:
            return "Monospaced"
        case .italic:
            return "Italic"
        }
    }

    func font(size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        switch self {
        case .classic:
            return .system(size: size, weight: weight, design: .default)
        case .rounded:
            return .system(size: size, weight: weight, design: .rounded)
        case .serif:
            return .system(size: size, weight: weight, design: .serif)
        case .monospaced:
            return .system(size: size, weight: weight, design: .monospaced)
        case .italic:
            return .system(size: size, weight: weight, design: .default).italic()
        }
    }
}

enum ChoiceDifficulty: String, CaseIterable, Identifiable {
    case easy
    case medium
    case hard

    var id: String { rawValue }

    var title: String {
        switch self {
        case .easy:
            return "Easy"
        case .medium:
            return "Medium"
        case .hard:
            return "Hard"
        }
    }

    var offsetRange: ClosedRange<Int> {
        switch self {
        case .easy:
            return -12...12
        case .medium:
            return -6...6
        case .hard:
            return -3...3
        }
    }
}
