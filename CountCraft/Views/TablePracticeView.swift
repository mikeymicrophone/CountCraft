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

    init(
        operation: OperationType,
        guesses: [PracticeGuess],
        profile: Profile?,
        onGuess: @escaping (PracticeGuess) -> Void
    ) {
        self.operation = operation
        self.guesses = guesses
        self.profile = profile
        self.onGuess = onGuess
        _axisMinX = AppStorage(wrappedValue: 0, "prefAxisMinX-\(operation.rawValue)")
        _axisMaxX = AppStorage(wrappedValue: 12, "prefAxisMaxX-\(operation.rawValue)")
        _axisMinY = AppStorage(wrappedValue: 0, "prefAxisMinY-\(operation.rawValue)")
        _axisMaxY = AppStorage(wrappedValue: 12, "prefAxisMaxY-\(operation.rawValue)")
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
                        }
                    )
                }
            }
            .sheet(isPresented: $showingPreferences) {
                PreferencesView()
            }
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

    private var progressView: some View {
        let attempts = filteredGuesses.count
        let correct = filteredGuesses.filter { $0.isCorrect }.count
        let accuracy = attempts == 0 ? 0 : Double(correct) / Double(attempts)
        let totalFacts = rowValues.count * columnValues.count
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
                    ForEach(columnValues, id: \.self) { value in
                        headerCell("\(value)", value: value)
                    }
                }

                ForEach(rowValues, id: \.self) { row in
                    HStack(spacing: 8) {
                        headerCell("\(row)", value: row)
                        ForEach(columnValues, id: \.self) { column in
                            let fact = MathFact(a: row, b: column)
                            let stats = statsByFact[FactKey(a: row, b: column)]
                            let answer = operation.answer(for: fact)
                            let answerLabel = NumberFormatting.string(from: answer)
                            let cellFontSize = fontSize(for: answerLabel)
                            Button {
                                if answersShown {
                                    activeSheet = TableSheetItem(fact: fact, mode: .explain)
                                } else {
                                    activeSheet = TableSheetItem(fact: fact, mode: .guess)
                                }
                            } label: {
                                FactCell(
                                    label: answersShown ? answerLabel : "?",
                                    status: stats,
                                    isInteractive: !answersShown,
                                    numberFont: numberFont(size: cellFontSize)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func headerCell(_ text: String, value: Int? = nil) -> some View {
        let color = value.flatMap { numberColor(for: $0) } ?? .primary
        return Text(text)
            .font(numberFont(size: 16))
            .frame(width: 44, height: 44)
            .foregroundColor(color)
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
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

    private func numberFont(size: CGFloat) -> Font {
        numberFontChoice.font(size: size, weight: .semibold)
    }

    private func numberColor(for value: Int) -> Color? {
        NumberStyling.color(for: value, enabled: colorCodedNumbers)
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

    private func fontSize(for label: String) -> CGFloat {
        let length = label.count
        if length <= 3 {
            return 16
        }
        if length == 4 {
            return 14
        }
        if length == 5 {
            return 12
        }
        return 10
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
