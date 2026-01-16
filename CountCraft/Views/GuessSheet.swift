//
//  GuessSheet.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import SwiftUI

struct GuessSheet: View {
    let operation: OperationType
    let fact: MathFact
    let inputMode: GuessInputMode
    let onSubmit: (MathFact, Int?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var entryText = ""
    @State private var options: [Int] = []

    var body: some View {
        VStack(spacing: 16) {
            Text("\(fact.a) \(operation.symbol) \(fact.b) = ?")
                .font(.largeTitle)
                .fontWeight(.semibold)

            switch inputMode {
            case .multipleChoice:
                VStack(spacing: 12) {
                    ForEach(options, id: \.self) { option in
                        Button {
                            submit(answer: option)
                        } label: {
                            Text("\(option)")
                                .font(.title2)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }

            case .freeEntry:
                VStack(spacing: 16) {
                    Text(entryText.isEmpty ? " " : entryText)
                        .font(.largeTitle)
                        .frame(width: 140, height: 56)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    keypad

                    Button("Submit") {
                        let trimmed = entryText.trimmingCharacters(in: .whitespacesAndNewlines)
                        submit(answer: Int(trimmed))
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(Int(entryText.trimmingCharacters(in: .whitespacesAndNewlines)) == nil)
                }
            }
        }
        .padding()
        .onAppear {
            if inputMode == .multipleChoice {
                options = PracticeMath.multipleChoiceOptions(
                    for: operation.answer(for: fact),
                    maxValue: operation.maxResult
                )
            }
        }
    }

    private func submit(answer: Int?) {
        onSubmit(fact, answer)
        dismiss()
    }

    private var keypad: some View {
        let columns = Array(repeating: GridItem(.fixed(64), spacing: 12), count: 3)
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(1...9, id: \.self) { number in
                keypadButton(label: "\(number)") {
                    appendDigit(number)
                }
            }

            keypadButton(label: "Del") {
                if !entryText.isEmpty {
                    entryText.removeLast()
                }
            }

            keypadButton(label: "0") {
                appendDigit(0)
            }

            keypadButton(label: "Clear") {
                entryText.removeAll()
            }
        }
    }

    private func keypadButton(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.title2)
                .frame(width: 64, height: 56)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func appendDigit(_ digit: Int) {
        guard entryText.count < 3 else { return }
        entryText.append(String(digit))
    }
}
