//
//  FactStats.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import Foundation

struct FactStats {
    var attempts: Int = 0
    var correct: Int = 0
    var lastWasCorrect: Bool?

    var accuracy: Double {
        attempts == 0 ? 0 : Double(correct) / Double(attempts)
    }

    var isMastered: Bool {
        attempts >= 5 && accuracy >= 0.8
    }

    mutating func add(guess: PracticeGuess) {
        attempts += 1
        if guess.isCorrect {
            correct += 1
        }
        lastWasCorrect = guess.isCorrect
    }

    func adding(guess: PracticeGuess) -> FactStats {
        var copy = self
        copy.add(guess: guess)
        return copy
    }
}
