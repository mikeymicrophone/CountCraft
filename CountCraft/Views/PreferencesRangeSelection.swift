//
//  PreferencesRangeSelection.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import Foundation

enum RangeSelection: String, CaseIterable, Identifiable {
    case addition
    case multiplication
    case exponent
    case sets
    case probability

    var id: String { rawValue }

    var operandRange: ClosedRange<Int> {
        OperationType(rawValue: rawValue)?.operandRange ?? 0...40
    }

    var title: String {
        switch self {
        case .addition:
            return "Add"
        case .multiplication:
            return "Multiply"
        case .exponent:
            return "Exponents"
        case .sets:
            return "Sets"
        case .probability:
            return "Probability"
        }
    }
}
