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

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Text(label)
                .font(.headline)
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
}
