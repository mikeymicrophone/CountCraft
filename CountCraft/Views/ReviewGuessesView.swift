//
//  ReviewGuessesView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import SwiftUI

struct ReviewGuessesView: View {
    let guesses: [PracticeGuess]

    private var sortedGuesses: [PracticeGuess] {
        guesses.sorted { $0.timestamp > $1.timestamp }
    }

    var body: some View {
        NavigationStack {
            List(sortedGuesses) { guess in
                VStack(alignment: .leading, spacing: 6) {
                    Text(guess.titleLine)
                        .font(.headline)

                    Text(guess.detailLine)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack(spacing: 8) {
                        Text(guess.isCorrect ? "Correct" : "Missed")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(guess.isCorrect ? .green : .red)

                        Text(guess.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 6)
            }
            .navigationTitle("Review Guesses")
        }
    }
}

private extension PracticeGuess {
    var operationSymbol: String {
        OperationType(rawValue: operation)?.symbol ?? "?"
    }

    var titleLine: String {
        "\(a) \(operationSymbol) \(b) = \(correctAnswer)"
    }

    var detailLine: String {
        let answerText = userAnswer.map(String.init) ?? "No answer"
        return "Your answer: \(answerText) • \(inputModeText)"
    }

    var inputModeText: String {
        GuessInputMode(rawValue: inputMode)?.title ?? "Unknown mode"
    }
}
