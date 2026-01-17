//
//  PairHistoryView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import SwiftUI

struct PairHistoryView: View {
    let guesses: [PracticeGuess]
    let operation: String
    let a: Int
    let b: Int

    private var matchingGuesses: [PracticeGuess] {
        guesses
            .filter { guess in
                guard guess.operation == operation else { return false }
                return (guess.a == a && guess.b == b) || (guess.a == b && guess.b == a)
            }
            .sorted { $0.timestamp > $1.timestamp }
    }

    var body: some View {
        List(matchingGuesses) { guess in
            ReviewGuessRow(guess: guess)
                .padding(.vertical, 6)
        }
        .navigationTitle("\(a) \(operationSymbol) \(b)")
        .onAppear {
            debugPrint("PairHistoryView \(#fileID): operation=\(operation) a=\(a) b=\(b) total=\(matchingGuesses.count)")
        }
    }

    private var operationSymbol: String {
        OperationType(rawValue: operation)?.symbol ?? "?"
    }
}
