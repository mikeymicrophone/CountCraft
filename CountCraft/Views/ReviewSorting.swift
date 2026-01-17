//
//  ReviewSorting.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import Foundation

enum SortKey: String, CaseIterable, Identifiable {
    case operandA
    case operation
    case operandB
    case guess
    case answer
    case check
    case difficulty
    case timestamp

    var id: String { rawValue }
}

enum SortDirection: String {
    case none
    case ascending
    case descending

    var next: SortDirection {
        switch self {
        case .none:
            return .ascending
        case .ascending:
            return .descending
        case .descending:
            return .none
        }
    }

    var iconName: String {
        switch self {
        case .none:
            return "arrow.up.arrow.down"
        case .ascending:
            return "arrow.up"
        case .descending:
            return "arrow.down"
        }
    }
}

struct SortDescriptor: Identifiable {
    let key: SortKey
    var direction: SortDirection

    var id: String { key.rawValue }
}
