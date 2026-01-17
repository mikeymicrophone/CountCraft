//
//  NumberFormatting.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import Foundation

struct NumberFormatting {
    static func string(from value: Int) -> String {
        formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    static func string(from value: Decimal) -> String {
        formatter.string(from: NSDecimalNumber(decimal: value)) ?? "\(value)"
    }

    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }()
}
