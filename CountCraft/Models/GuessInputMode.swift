//
//  GuessInputMode.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import Foundation

enum GuessInputMode: String, CaseIterable, Identifiable {
    case multipleChoice
    case freeEntry

    var id: String { rawValue }
    var title: String {
        switch self {
        case .multipleChoice:
            return "Multiple Choice"
        case .freeEntry:
            return "Free Entry"
        }
    }
}
