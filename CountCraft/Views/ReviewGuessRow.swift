//
//  ReviewGuessRow.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import SwiftUI

struct ReviewGuessRow: View {
    let guess: PracticeGuess
    @AppStorage("prefColorCodedNumbers") private var colorCodedNumbers = false
    @AppStorage("prefNumberFont") private var numberFontRaw = NumberFontChoice.rounded.rawValue

    var body: some View {
        HStack(spacing: 12) {
            numberStyle.outlinedNumberText(guess.a)
                .frame(width: ReviewColumns.operand, alignment: .leading)

            Text(operationSymbol)
                .foregroundColor(.secondary)
                .frame(width: ReviewColumns.operatorSymbol, alignment: .center)

            numberStyle.outlinedNumberText(guess.b)
                .frame(width: ReviewColumns.operand, alignment: .leading)

            if let answer = guess.userAnswer {
                numberStyle.outlinedNumberText(answer)
                    .frame(width: ReviewColumns.guess, alignment: .leading)
            } else {
                Text("—")
                    .foregroundColor(.secondary)
                    .frame(width: ReviewColumns.guess, alignment: .leading)
            }

            numberStyle.outlinedNumberText(guess.correctAnswer)
                .frame(width: ReviewColumns.answer, alignment: .leading)

            Image(systemName: guess.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(guess.isCorrect ? .green : .red)
                .frame(width: ReviewColumns.check, alignment: .leading)

            Text(difficultyText)
                .frame(width: ReviewColumns.difficulty, alignment: .leading)

            Text(guess.timestamp, style: .relative)
                .foregroundColor(.secondary)
                .frame(width: ReviewColumns.when, alignment: .trailing)
        }
        .font(.subheadline)
    }

    private var difficultyText: String {
        guard let value = guess.difficulty,
              let difficulty = ChoiceDifficulty(rawValue: value) else {
            return "Unknown"
        }
        return difficulty.title
    }

    private var operationSymbol: String {
        OperationType(rawValue: guess.operation)?.symbol ?? "?"
    }

    private var numberStyle: NumberStyle {
        NumberStyle(
            fontChoice: NumberFontChoice(rawValue: numberFontRaw) ?? .rounded,
            colorCoded: colorCodedNumbers
        )
    }
}
