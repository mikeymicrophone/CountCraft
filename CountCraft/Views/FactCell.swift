//
//  FactCell.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import SwiftUI

struct FactCell: View {
    let label: String
    let status: FactStats?
    let isInteractive: Bool
    let numberFont: Font

    var body: some View {
        ZStack(alignment: badgeAlignment) {
            Text(label)
                .font(numberFont)
                .frame(width: 44, height: 44)
                .foregroundColor(.primary)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            if let last = status?.lastWasCorrect {
                Image(systemName: last ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.caption2)
                    .foregroundColor(last ? .green : .red)
                    .padding(4)
            }
        }
    }

    private var backgroundColor: Color {
        guard isInteractive else {
            return Color(.secondarySystemBackground)
        }

        if status?.isMastered == true {
            return Color.green.opacity(0.25)
        }
        if status?.lastWasCorrect == false {
            return Color.red.opacity(0.2)
        }
        return Color(.secondarySystemBackground)
    }

    private var badgeAlignment: Alignment {
        guard let correctCount = status?.correct else { return .topTrailing }
        switch correctCount % 4 {
        case 1:
            return .bottomTrailing
        case 2:
            return .bottomLeading
        case 3:
            return .topLeading
        default:
            return .topTrailing
        }
    }
}
