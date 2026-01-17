//
//  ProbabilityTypes.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import Foundation

enum ProbabilityMode: String, CaseIterable, Identifiable {
    case coin
    case dice
    case cards

    var id: String { rawValue }

    var title: String {
        switch self {
        case .coin:
            return "Coin"
        case .dice:
            return "Dice"
        case .cards:
            return "Cards"
        }
    }
}

enum ProbabilityFormat: String, CaseIterable, Identifiable {
    case fraction
    case decimal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fraction:
            return "Fraction"
        case .decimal:
            return "Decimal"
        }
    }
}

enum CardFocus: String, CaseIterable, Identifiable {
    case face
    case suit
    case color

    var id: String { rawValue }

    var title: String {
        switch self {
        case .face:
            return "Face"
        case .suit:
            return "Suit"
        case .color:
            return "Color"
        }
    }

    var rowLabel: String {
        switch self {
        case .face:
            return "aces"
        case .suit:
            return "spades"
        case .color:
            return "black cards"
        }
    }

    var successOutcomes: Int {
        switch self {
        case .face:
            return 4
        case .suit:
            return 13
        case .color:
            return 26
        }
    }
}
