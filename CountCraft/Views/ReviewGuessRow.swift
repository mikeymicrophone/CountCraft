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
            Text(NumberFormatting.string(from: guess.a))
                .foregroundColor(numberStyle.primaryColor(for: guess.a))
                .frame(width: ReviewColumns.operand, alignment: .leading)

            Text(operationSymbol)
                .foregroundColor(.secondary)
                .frame(width: ReviewColumns.operatorSymbol, alignment: .center)

            Text(NumberFormatting.string(from: guess.b))
                .foregroundColor(numberStyle.primaryColor(for: guess.b))
                .frame(width: ReviewColumns.operand, alignment: .leading)

            Text(guessAnswerText)
                .foregroundColor(guessAnswerColor)
                .frame(width: ReviewColumns.guess, alignment: .leading)

            Text(NumberFormatting.string(from: guess.correctAnswer))
                .foregroundColor(numberStyle.primaryColor(for: guess.correctAnswer))
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

    private var guessAnswerText: String {
        guard let answer = guess.userAnswer else { return "—" }
        return NumberFormatting.string(from: answer)
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

    private var guessAnswerColor: Color {
        guard let answer = guess.userAnswer else { return .secondary }
        return numberStyle.primaryColor(for: answer)
    }

    private var numberStyle: NumberStyle {
        NumberStyle(
            fontChoice: NumberFontChoice(rawValue: numberFontRaw) ?? .rounded,
            colorCoded: colorCodedNumbers
        )
    }
}
