//
//  TablePracticeView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import SwiftUI

struct TablePracticeView: View {
    private let operation: OperationType
    private let guesses: [PracticeGuess]
    private let onGuess: (PracticeGuess) -> Void

    @State private var answersShown = true
    @State private var inputMode: GuessInputMode = .multipleChoice
    @State private var activeFact: MathFact?

    private let numbers = Array(0...12)

    init(operation: OperationType, guesses: [PracticeGuess], onGuess: @escaping (PracticeGuess) -> Void) {
        self.operation = operation
        self.guesses = guesses
        self.onGuess = onGuess
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                progressView
                controlsView
                tableGrid
            }
            .padding()
            .navigationTitle("\(operation.title) Tables")
            .sheet(item: $activeFact) { fact in
                GuessSheet(
                    operation: operation,
                    fact: fact,
                    inputMode: inputMode,
                    onSubmit: recordGuess(for:userAnswer:)
                )
            }
        }
    }

    private var filteredGuesses: [PracticeGuess] {
        guesses.filter { $0.operation == operation.rawValue }
    }

    private var statsByFact: [FactKey: FactStats] {
        var stats: [FactKey: FactStats] = [:]
        for guess in filteredGuesses {
            let key = FactKey(a: guess.a, b: guess.b)
            let current = stats[key] ?? FactStats()
            let updated = current.adding(guess: guess)
            stats[key] = updated
        }
        return stats
    }

    private var progressView: some View {
        let attempts = filteredGuesses.count
        let correct = filteredGuesses.filter { $0.isCorrect }.count
        let accuracy = attempts == 0 ? 0 : Double(correct) / Double(attempts)
        let totalFacts = numbers.count * numbers.count
        let mastered = statsByFact.values.filter { $0.isMastered }.count

        return VStack(alignment: .leading, spacing: 8) {
            Text("Progress")
                .font(.headline)
            HStack(spacing: 16) {
                ProgressBadge(title: "Attempts", value: "\(attempts)")
                ProgressBadge(title: "Accuracy", value: "\(Int(accuracy * 100))%")
                ProgressBadge(title: "Mastered", value: "\(mastered)/\(totalFacts)")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var controlsView: some View {
        VStack(spacing: 12) {
            Toggle(isOn: $answersShown) {
                Text(answersShown ? "Answers Shown" : "Blank for Guessing")
                    .font(.headline)
            }

            Picker("Guess Mode", selection: $inputMode) {
                ForEach(GuessInputMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .disabled(answersShown)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var tableGrid: some View {
        ScrollView([.vertical, .horizontal]) {
            LazyVStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    headerCell("")
                    ForEach(numbers, id: \.self) { value in
                        headerCell("\(value)")
                    }
                }

                ForEach(numbers, id: \.self) { row in
                    HStack(spacing: 8) {
                        headerCell("\(row)")
                        ForEach(numbers, id: \.self) { column in
                            let fact = MathFact(a: row, b: column)
                            let stats = statsByFact[FactKey(a: row, b: column)]
                            let answer = operation.answer(for: fact)
                            Button {
                                if !answersShown {
                                    activeFact = fact
                                }
                            } label: {
                                FactCell(
                                    label: answersShown ? "\(answer)" : "?",
                                    status: stats,
                                    isInteractive: !answersShown
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(answersShown)
                        }
                    }
                }
            }
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func headerCell(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .frame(width: 44, height: 44)
            .foregroundColor(.primary)
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func recordGuess(for fact: MathFact, userAnswer: Int?) {
        let correctAnswer = operation.answer(for: fact)
        let isCorrect = userAnswer == correctAnswer
        let guess = PracticeGuess(
            operation: operation,
            a: fact.a,
            b: fact.b,
            correctAnswer: correctAnswer,
            userAnswer: userAnswer,
            isCorrect: isCorrect,
            inputMode: inputMode,
            answersShown: answersShown
        )
        onGuess(guess)
    }
}
