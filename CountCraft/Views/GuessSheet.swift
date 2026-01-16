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

    @AppStorage("prefColorCodedNumbers") private var colorCodedNumbers = false
    @AppStorage("prefNumberFont") private var numberFontRaw = NumberFontChoice.rounded.rawValue
    @AppStorage("prefChoiceDifficulty") private var difficultyRaw = ChoiceDifficulty.medium.rawValue

    @Environment(\.dismiss) private var dismiss
    @State private var entryText = ""
    @State private var options: [Int] = []

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                if operation == .exponent {
                    expandedExponentView
                }
                equationView
            }

            switch inputMode {
            case .multipleChoice:
                VStack(spacing: 12) {
                    ForEach(options, id: \.self) { option in
                        Button {
                            submit(answer: option)
                        } label: {
                            Text(NumberFormatting.string(from: option))
                                .font(numberFont(size: 22, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .foregroundColor(numberColor(for: option) ?? .primary)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }

            case .freeEntry:
                VStack(spacing: 16) {
                    Text(entryText.isEmpty ? " " : NumberFormatting.string(from: entryValue))
                        .font(numberFont(size: 34, weight: .semibold))
                        .frame(width: 140, height: 56)
                        .foregroundColor(entryColor)
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
                    for: operation,
                    fact: fact,
                    maxValue: operation.maxResult,
                    difficulty: choiceDifficulty
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
                .font(numberFont(size: 22, weight: .semibold))
                .frame(width: 64, height: 56)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func appendDigit(_ digit: Int) {
        guard entryText.count < 3 else { return }
        entryText.append(String(digit))
    }

    private var equationView: some View {
        HStack(spacing: 8) {
            if operation == .exponent {
                Text("\(fact.a)")
                    .foregroundColor(numberColor(for: fact.a) ?? .primary)
                Text("\(fact.b)")
                    .font(numberFont(size: 20, weight: .semibold))
                    .baselineOffset(16)
                    .foregroundColor(numberColor(for: fact.b) ?? .primary)
            } else {
                Text("\(fact.a)")
                    .foregroundColor(numberColor(for: fact.a) ?? .primary)
                Text(operation.symbol)
                    .foregroundColor(.primary)
                Text("\(fact.b)")
                    .foregroundColor(numberColor(for: fact.b) ?? .primary)
            }
            Text("=")
                .foregroundColor(.primary)
            Text("?")
                .foregroundColor(.primary)
        }
        .font(numberFont(size: 34, weight: .semibold))
    }

    private var numberFontChoice: NumberFontChoice {
        NumberFontChoice(rawValue: numberFontRaw) ?? .rounded
    }

    private var choiceDifficulty: ChoiceDifficulty {
        ChoiceDifficulty(rawValue: difficultyRaw) ?? .medium
    }

    private func numberFont(size: CGFloat, weight: Font.Weight) -> Font {
        numberFontChoice.font(size: size, weight: weight)
    }

    private func numberColor(for value: Int) -> Color? {
        NumberStyling.color(for: value, enabled: colorCodedNumbers)
    }

    private var entryColor: Color {
        guard let value = Int(entryText) else { return .primary }
        return numberColor(for: value) ?? .primary
    }

    private var entryValue: Int {
        Int(entryText) ?? 0
    }

    private var expandedExponentView: some View {
        let baseText = NumberFormatting.string(from: fact.a)
        if fact.b == 0 {
            return AnyView(
                VStack(spacing: 4) {
                    Text(baseText)
                    Rectangle()
                        .frame(width: 40, height: 2)
                    Text(baseText)
                }
                .font(numberFont(size: 22, weight: .semibold))
                .foregroundColor(.secondary)
            )
        }

        let factors = Array(repeating: baseText, count: fact.b)
        return AnyView(
            Text(factors.joined(separator: " x "))
                .font(numberFont(size: 22, weight: .semibold))
                .foregroundColor(.secondary)
        )
    }
}
