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
    private let profile: Profile?
    private let onGuess: (PracticeGuess) -> Void
    private let onSwitchOperation: ((OperationType, MathFact) -> Void)?

    @AppStorage("prefColorCodedNumbers") private var colorCodedNumbers = false
    @AppStorage("prefNumberFont") private var numberFontRaw = NumberFontChoice.rounded.rawValue
    @AppStorage("prefChoiceDifficulty") private var difficultyRaw = ChoiceDifficulty.medium.rawValue
    @AppStorage private var axisMinX: Int
    @AppStorage private var axisMaxX: Int
    @AppStorage private var axisMinY: Int
    @AppStorage private var axisMaxY: Int

    @State private var answersShown = true
    @State private var inputMode: GuessInputMode = .multipleChoice
    @State private var activeSheet: TableSheetItem?
    @State private var showingPreferences = false
    @Binding private var pendingExplanation: MathFact?

    init(
        operation: OperationType,
        guesses: [PracticeGuess],
        profile: Profile?,
        onGuess: @escaping (PracticeGuess) -> Void,
        onSwitchOperation: ((OperationType, MathFact) -> Void)? = nil,
        pendingExplanation: Binding<MathFact?> = .constant(nil)
    ) {
        self.operation = operation
        self.guesses = guesses
        self.profile = profile
        self.onGuess = onGuess
        self.onSwitchOperation = onSwitchOperation
        self._pendingExplanation = pendingExplanation
        _axisMinX = AppStorage(wrappedValue: 0, "prefAxisMinX-\(operation.rawValue)")
        _axisMaxX = AppStorage(wrappedValue: 12, "prefAxisMaxX-\(operation.rawValue)")
        _axisMinY = AppStorage(wrappedValue: 0, "prefAxisMinY-\(operation.rawValue)")
        _axisMaxY = AppStorage(wrappedValue: 12, "prefAxisMaxY-\(operation.rawValue)")
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TablePracticeProgressView(
                    attempts: filteredGuesses.count,
                    correct: filteredGuesses.filter { $0.isCorrect }.count,
                    mastered: statsByFact.values.filter { $0.isMastered }.count,
                    totalFacts: rowValues.count * columnValues.count
                )
                TablePracticeControlsView(
                    answersShown: $answersShown,
                    inputMode: $inputMode
                )
                TablePracticeGridView(
                    operation: operation,
                    rowValues: rowValues,
                    columnValues: columnValues,
                    statsByFact: statsByFact,
                    answersShown: answersShown,
                    numberStyle: numberStyle,
                    onSelectFact: { fact in
                        activeSheet = TableSheetItem(
                            fact: fact,
                            mode: answersShown ? .explain : .guess
                        )
                    }
                )
            }
            .padding()
            .navigationTitle("\(operation.title) Tables")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingPreferences = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(item: $activeSheet) { item in
                switch item.mode {
                case .guess:
                    GuessSheet(
                        operation: operation,
                        fact: item.fact,
                        inputMode: inputMode,
                        onSubmit: recordGuess(for:userAnswer:)
                    )
                case .explain:
                    ExplanationSheet(
                        operation: operation,
                        fact: item.fact,
                        rowValues: rowValues,
                        columnValues: columnValues,
                        onNavigate: { newFact in
                            activeSheet = TableSheetItem(fact: newFact, mode: .explain)
                        },
                        onSwitchOperation: onSwitchOperation.map { switchOperation in
                            { target in
                                activeSheet = nil
                                switchOperation(target, item.fact)
                            }
                        }
                    )
                }
            }
            .sheet(isPresented: $showingPreferences) {
                PreferencesView()
            }
        }
        .onAppear {
            openPendingExplanationIfNeeded()
        }
        .onChange(of: pendingExplanation) { _, _ in
            openPendingExplanationIfNeeded()
        }
    }

    private var filteredGuesses: [PracticeGuess] {
        let rowSet = Set(rowValues)
        let columnSet = Set(columnValues)
        return guesses.filter { guess in
            guess.operation == operation.rawValue
                && rowSet.contains(guess.a)
                && columnSet.contains(guess.b)
        }
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

    private func recordGuess(for fact: MathFact, userAnswer: Int?) {
        let difficulty = ChoiceDifficulty(rawValue: difficultyRaw) ?? .medium
        let correctAnswer = operation.answer(for: fact)
        let isCorrect = userAnswer == correctAnswer
        let guess = PracticeGuess(
            operation: operation,
            difficulty: difficulty,
            a: fact.a,
            b: fact.b,
            correctAnswer: correctAnswer,
            userAnswer: userAnswer,
            isCorrect: isCorrect,
            inputMode: inputMode,
            answersShown: answersShown,
            profile: profile
        )
        onGuess(guess)
    }

    private var numberFontChoice: NumberFontChoice {
        NumberFontChoice(rawValue: numberFontRaw) ?? .rounded
    }

    private var numberStyle: NumberStyle {
        NumberStyle(fontChoice: numberFontChoice, colorCoded: colorCodedNumbers)
    }

    private func openPendingExplanationIfNeeded() {
        guard let fact = pendingExplanation else { return }
        activeSheet = TableSheetItem(fact: fact, mode: .explain)
        pendingExplanation = nil
    }

    private var rowValues: [Int] {
        normalizedRange(minValue: axisMinY, maxValue: axisMaxY)
    }

    private var columnValues: [Int] {
        normalizedRange(minValue: axisMinX, maxValue: axisMaxX)
    }

    private func normalizedRange(minValue: Int, maxValue: Int) -> [Int] {
        let lower = min(max(minValue, 0), 12)
        let upper = min(max(maxValue, 0), 12)
        if lower <= upper {
            return Array(lower...upper)
        }
        return Array(upper...lower)
    }
}

private enum TableSheetMode {
    case guess
    case explain
}

private struct TableSheetItem: Identifiable {
    let id = UUID()
    let fact: MathFact
    let mode: TableSheetMode
}
