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
            Group {
                if entryText.isEmpty {
                    Text(" ")
                        .foregroundColor(.primary)
                } else {
                    numberStyle.outlinedNumberText(entryValue)
                }
            }
            .font(numberStyle.font(size: 34, weight: .semibold))
            .frame(width: 140, height: 56)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .numberBorder(entryBorderColor, cornerRadius: 12)

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

    private var entryBorderColor: Color? {
        guard let value = Int(entryText) else { return nil }
        return numberStyle.borderColor(for: value)
    }

    private func appendDigit(_ digit: Int) {
        guard entryText.count < 3 else { return }
        entryText.append(String(digit))
    }
}
