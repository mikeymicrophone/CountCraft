//
//  GuessFreeEntryView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import SwiftUI

struct GuessFreeEntryView: View {
    @Binding var entryText: String
    let numberStyle: NumberStyle
    let onSubmit: (Int?) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(entryText.isEmpty ? " " : NumberFormatting.string(from: entryValue))
                .font(numberStyle.font(size: 34, weight: .semibold))
                .frame(width: 140, height: 56)
                .foregroundColor(entryColor)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            GuessKeypadView(
                numberStyle: numberStyle,
                onDigit: appendDigit,
                onDelete: {
                    if !entryText.isEmpty {
                        entryText.removeLast()
                    }
                },
                onClear: {
                    entryText.removeAll()
                }
            )

            Button("Submit") {
                let trimmed = entryText.trimmingCharacters(in: .whitespacesAndNewlines)
                onSubmit(Int(trimmed))
            }
            .buttonStyle(.borderedProminent)
            .disabled(Int(entryText.trimmingCharacters(in: .whitespacesAndNewlines)) == nil)
        }
    }

    private var entryValue: Int {
        Int(entryText) ?? 0
    }

    private var entryColor: Color {
        guard let value = Int(entryText) else { return .primary }
        return numberStyle.primaryColor(for: value)
    }

    private func appendDigit(_ digit: Int) {
        guard entryText.count < 3 else { return }
        entryText.append(String(digit))
    }
}
