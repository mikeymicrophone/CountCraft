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

    @AppStorage("prefHintsShown") private var hintsShown = true
    @AppStorage("prefColorCodedNumbers") private var colorCodedNumbers = false
    @AppStorage("prefNumberFont") private var numberFontRaw = NumberFontChoice.rounded.rawValue
    @AppStorage("prefChoiceDifficulty") private var difficultyRaw = ChoiceDifficulty.medium.rawValue

    @Environment(\.dismiss) private var dismiss
    @State private var entryText = ""
    @State private var options: [Int] = []

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                if hintsShown {
                    GuessHintView(
                        operation: operation,
                        fact: fact,
                        numberStyle: numberStyle
                    )
                }
                GuessEquationView(
                    operation: operation,
                    fact: fact,
                    numberStyle: numberStyle
                )
            }

            switch inputMode {
            case .multipleChoice:
                GuessChoiceListView(options: options, numberStyle: numberStyle) { option in
                    submit(answer: option)
                }

            case .freeEntry:
                GuessFreeEntryView(entryText: $entryText, numberStyle: numberStyle) { answer in
                    submit(answer: answer)
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

    private var numberFontChoice: NumberFontChoice {
        NumberFontChoice(rawValue: numberFontRaw) ?? .rounded
    }

    private var numberStyle: NumberStyle {
        NumberStyle(fontChoice: numberFontChoice, colorCoded: colorCodedNumbers)
    }

    private var choiceDifficulty: ChoiceDifficulty {
        ChoiceDifficulty(rawValue: difficultyRaw) ?? .medium
    }
}
