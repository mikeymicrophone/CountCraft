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
                VStack(spacing: 12) {
                    TextField("Type answer", text: $entryText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)

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
}
