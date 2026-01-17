//
//  CountCraftTests.swift
//  CountCraftTests
//
//  Created by Mike Schwab on 1/16/26.
//

import Foundation
import Testing
@testable import CountCraft

struct CountCraftTests {
    @Test func operationAnswers() {
        let fact = MathFact(a: 7, b: 6)

        #expect(OperationType.addition.answer(for: fact) == 13)
        #expect(OperationType.multiplication.answer(for: fact) == 42)
        #expect(OperationType.exponent.answer(for: MathFact(a: 2, b: 5)) == 32)
        #expect(OperationType.exponent.answer(for: MathFact(a: 5, b: 0)) == 1)
        #expect(OperationType.exponent.answer(for: MathFact(a: 5, b: -1)) == 0)
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

    @Test func multipleChoiceOptionsIncludeAnswerForMultiplication() {
        let fact = MathFact(a: 6, b: 7)
        let options = PracticeMath.multipleChoiceOptions(
            for: .multiplication,
            fact: fact,
            maxValue: 144,
            difficulty: .hard
        )

        #expect(options.count == 4)
        #expect(Set(options).count == 4)
        #expect(options.contains(42))
    }

    @Test func mathFactIdUsesOperands() {
        let fact = MathFact(a: 2, b: 3)
        #expect(fact.id == "2-3")
    }

    @Test func choiceDifficultyRanges() {
        #expect(ChoiceDifficulty.easy.offsetRange == -12...12)
        #expect(ChoiceDifficulty.medium.offsetRange == -6...6)
        #expect(ChoiceDifficulty.hard.offsetRange == -3...3)
    }

    @Test func numberFormattingPreservesDigits() {
        let value = 1234567
        let formatted = NumberFormatting.string(from: value)
        let digitsOnly = formatted.unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }
        let digitsString = String(String.UnicodeScalarView(digitsOnly))

        #expect(digitsString == "\(value)")
    }

    @Test func numberStylingRespectsBoundsAndToggle() {
        #expect(NumberStyling.color(for: 5, enabled: false) == nil)
        #expect(NumberStyling.color(for: 13, enabled: true) == nil)
        #expect(NumberStyling.color(for: 0, enabled: true) != nil)
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
        answersShown: false,
        profile: nil
    )
}
