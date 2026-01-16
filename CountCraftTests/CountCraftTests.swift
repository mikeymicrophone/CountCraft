//
//  CountCraftTests.swift
//  CountCraftTests
//
//  Created by Mike Schwab on 1/16/26.
//

import Testing
@testable import CountCraft

struct CountCraftTests {
    @Test func operationAnswers() {
        let fact = MathFact(a: 7, b: 6)

        #expect(OperationType.addition.answer(for: fact) == 13)
        #expect(OperationType.multiplication.answer(for: fact) == 42)
    }

    @Test func factStatsTracksAccuracyAndMastery() {
        var stats = FactStats()
        let guesses = [
            makeGuess(correct: true),
            makeGuess(correct: true),
            makeGuess(correct: false),
            makeGuess(correct: true),
            makeGuess(correct: true)
        ]

        for guess in guesses {
            stats.add(guess: guess)
        }

        #expect(stats.attempts == 5)
        #expect(stats.correct == 4)
        #expect(stats.accuracy == 0.8)
        #expect(stats.isMastered)
        #expect(stats.lastWasCorrect == true)
    }

    @Test func multipleChoiceOptionsIncludeAnswer() {
        let fact = MathFact(a: 4, b: 5)
        let options = PracticeMath.multipleChoiceOptions(
            for: .addition,
            fact: fact,
            maxValue: 24
        )

        #expect(options.count == 4)
        #expect(Set(options).count == 4)
        #expect(options.contains(9))
        #expect(options.allSatisfy { (0...24).contains($0) })
    }
}

private func makeGuess(correct: Bool) -> PracticeGuess {
    let answer = 10
    return PracticeGuess(
        operation: .addition,
        difficulty: .medium,
        a: 4,
        b: 6,
        correctAnswer: answer,
        userAnswer: correct ? answer : 7,
        isCorrect: correct,
        inputMode: .multipleChoice,
        answersShown: false
    )
}
