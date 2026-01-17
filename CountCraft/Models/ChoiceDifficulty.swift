//
//  ChoiceDifficulty.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import Foundation

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
