//
//  GuessKeypadView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import SwiftUI

struct GuessKeypadView: View {
    let numberStyle: NumberStyle
    let onDigit: (Int) -> Void
    let onDelete: () -> Void
    let onClear: () -> Void

    var body: some View {
        let columns = Array(repeating: GridItem(.fixed(64), spacing: 12), count: 3)
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(1...9, id: \.self) { number in
                keypadButton(label: "\(number)") {
                    onDigit(number)
                }
            }

            keypadButton(label: "Del") {
                onDelete()
            }

            keypadButton(label: "0") {
                onDigit(0)
            }

            keypadButton(label: "Clear") {
                onClear()
            }
        }
    }

    private func keypadButton(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(numberStyle.font(size: 22, weight: .semibold))
                .frame(width: 64, height: 56)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
