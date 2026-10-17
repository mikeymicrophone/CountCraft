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
    @Test func exponentAxesClampPreviouslySavedRanges() {
        let operation = OperationType.exponent
        #expect(operation.axisValues(minValue: 0, maxValue: 40, step: 1) == Array(0...12))
        #expect(operation.axisValues(minValue: 18, maxValue: 40, step: 1) == [12])
        #expect(operation.axisValues(minValue: 40, maxValue: -1, step: 1) == Array(0...12))
        #expect(RangeSelection.exponent.operandRange == operation.operandRange)

        for a in operation.operandRange {
            for b in operation.operandRange {
                let fact = MathFact(a: a, b: b)
                #expect(operation.supports(fact))
                #expect(operation.answer(for: fact) >= 0)
            }
        }
        #expect(operation.answer(for: MathFact(a: 12, b: 12)) == 8_916_100_448_256)
    }

    @Test func operationSwitchRejectsLargeExponentOperands() {
        #expect(!OperationType.exponent.supports(MathFact(a: 12, b: 18)))
        #expect(!OperationType.exponent.supports(MathFact(a: 40, b: 12)))
        #expect(OperationType.multiplication.supports(MathFact(a: 40, b: 40)))
        #expect(OperationType.multiplication.axisValues(minValue: 0, maxValue: 40, step: 10) == [0, 10, 20, 30, 40])
    }

    @Test func operationAnswers() {
        let fact = MathFact(a: 7, b: 6)

        #expect(OperationType.addition.answer(for: fact) == 13)
        #expect(OperationType.multiplication.answer(for: fact) == 42)
        #expect(OperationType.exponent.answer(for: MathFact(a: 2, b: 5)) == 32)
        #expect(OperationType.exponent.answer(for: MathFact(a: 5, b: 0)) == 1)
        #expect(OperationType.exponent.answer(for: MathFact(a: 5, b: -1)) == 0)
        #expect(OperationType.sets.answer(for: MathFact(a: 2, b: 3)) == 6)
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

    @Test func combinatoricsChooseSymmetry() {
        #expect(Combinatorics.choose(n: 8, k: 2) == 28)
        #expect(Combinatorics.choose(n: 8, k: 6) == 28)
        #expect(Combinatorics.choose(n: 8, k: 0) == 1)
    }

    @Test func probabilityAtLeastSuccessesForDice() {
        let fraction = Probability.atLeastSuccesses(
            trials: 7,
            successesAtLeast: 7,
            successOutcomes: 1,
            totalOutcomes: 6
        )
        #expect(fraction.numerator == Decimal(1))
        #expect(fraction.denominator == Decimal(279936))
    }

    @Test func fractionReducesValues() {
        let fraction = Fraction(numerator: 6, denominator: 8)
        #expect(fraction.numerator == Decimal(3))
        #expect(fraction.denominator == Decimal(4))
    }

    @Test func combinatoricsChooseHandlesLargeInputsWithoutOverflow() {
        #expect(Combinatorics.choose(n: 40, k: 20) == 137_846_528_820)
    }

    @Test func probabilityColumnMatchesPointQueriesAndHandlesLargeTrials() {
        let column = Probability.columnAtLeastSuccesses(
            trials: 6,
            successOutcomes: 1,
            totalOutcomes: 6
        )
        #expect(column.count == 7)
        for threshold in 0...6 {
            let expected = Probability.atLeastSuccesses(
                trials: 6,
                successesAtLeast: threshold,
                successOutcomes: 1,
                totalOutcomes: 6
            )
            #expect(column[threshold] == expected)
        }

        let highCardPulls = Probability.atLeastSuccesses(
            trials: 30,
            successesAtLeast: 1,
            successOutcomes: 13,
            totalOutcomes: 52
        )
        #expect(highCardPulls.value > 0.99)
        #expect(highCardPulls.value <= 1.0)
    }

    @Test func reviewGuessesFirstTimeFilterDistinguishesOperations() {
        let additionGuess = PracticeGuess(
            operation: .addition,
            difficulty: .medium,
            a: 2,
            b: 3,
            correctAnswer: 5,
            userAnswer: 5,
            isCorrect: true,
            inputMode: .multipleChoice,
            answersShown: false,
            profile: nil
        )
        let multiplicationGuess = PracticeGuess(
            operation: .multiplication,
            difficulty: .medium,
            a: 2,
            b: 3,
            correctAnswer: 6,
            userAnswer: 6,
            isCorrect: true,
            inputMode: .multipleChoice,
            answersShown: false,
            profile: nil
        )
        let viewModel = ReviewGuessesViewModel(guesses: [additionGuess, multiplicationGuess])
        viewModel.onlyFirstTime = true
        #expect(viewModel.filteredGuesses.count == 2)
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
