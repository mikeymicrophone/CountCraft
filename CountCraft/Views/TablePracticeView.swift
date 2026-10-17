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
    @AppStorage private var axisStepX: Int
    @AppStorage private var axisStepY: Int

    @State private var answersShown = true
    @State private var inputMode: GuessInputMode = .multipleChoice
    @State private var activeSheet: TableSheetItem?
    @State private var showingPreferences = false
    @Binding private var pendingExplanation: MathFact?
    @State private var isAutoExplaining = false
    @State private var autoExplainFact: MathFact?
    @State private var autoExplainTask: Task<Void, Never>?
    @State private var gridData = GridData.empty
    @State private var gridToken = 0

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
        _axisStepX = AppStorage(wrappedValue: 1, "prefAxisStepX-\(operation.rawValue)")
        _axisStepY = AppStorage(wrappedValue: 1, "prefAxisStepY-\(operation.rawValue)")
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TablePracticeProgressView(
                    attempts: gridData.attempts,
                    correct: gridData.correct,
                    mastered: gridData.mastered,
                    totalFacts: gridData.rowValues.count * gridData.columnValues.count
                )
                if operation != .sets {
                    TablePracticeControlsView(
                        answersShown: $answersShown,
                        inputMode: $inputMode
                    )
                }
                HStack {
                    Button {
                        if isAutoExplaining {
                            stopAutoExplain()
                        } else {
                            startAutoExplain()
                        }
                    } label: {
                        Label(
                            isAutoExplaining ? "Pause explanations" : "Auto explanations",
                            systemImage: isAutoExplaining ? "pause.circle.fill" : "play.circle.fill"
                        )
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
                TablePracticeGridHost(
                    token: gridToken,
                    operation: operation,
                    rowValues: gridData.rowValues,
                    columnValues: gridData.columnValues,
                    statsByFact: gridData.statsByFact,
                    answersShown: answersShown,
                    numberStyle: numberStyle,
                    onSelectFact: { fact in
                        stopAutoExplain()
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
                        rowValues: gridData.rowValues,
                        columnValues: gridData.columnValues,
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
            refreshGridData()
            openPendingExplanationIfNeeded()
        }
        .onChange(of: guesses) { _, _ in
            refreshGridData()
        }
        .onChange(of: currentAxis) { _, _ in
            refreshGridData()
        }
        .onChange(of: pendingExplanation) { _, _ in
            openPendingExplanationIfNeeded()
        }
        .onDisappear {
            stopAutoExplain()
        }
        .overlay(autoExplainOverlay)
    }

    private var currentAxis: AxisValues {
        AxisValues(
            minX: axisMinX,
            maxX: axisMaxX,
            minY: axisMinY,
            maxY: axisMaxY,
            stepX: axisStepX,
            stepY: axisStepY
        )
    }

    private func refreshGridData() {
        gridData = Self.makeGridData(guesses: guesses, operation: operation, axis: currentAxis)
        gridToken &+= 1
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
        pendingExplanation = nil
        guard operation.supports(fact) else { return }
        activeSheet = TableSheetItem(fact: fact, mode: .explain)
    }

    private var autoExplainOverlay: some View {
        Group {
            if isAutoExplaining, let fact = autoExplainFact {
                ZStack {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                        .onTapGesture {
                            stopAutoExplain()
                        }
                    ExplanationSheet(
                        operation: operation,
                        fact: fact,
                        rowValues: gridData.rowValues,
                        columnValues: gridData.columnValues,
                        onNavigate: { newFact in
                            autoExplainFact = newFact
                        },
                        onSwitchOperation: onSwitchOperation.map { switchOperation in
                            { target in
                                stopAutoExplain()
                                switchOperation(target, fact)
                            }
                        }
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(.systemBackground))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(radius: 16)
                    .padding(24)
                }
                .transition(.opacity)
            }
        }
    }

    private func startAutoExplain() {
        stopAutoExplain(clearFact: false)
        autoExplainFact = randomFact(excluding: nil)
        guard autoExplainFact != nil else { return }
        activeSheet = nil
        isAutoExplaining = true
        autoExplainTask = Task { @MainActor in
            while isAutoExplaining {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                guard isAutoExplaining else { break }
                autoExplainFact = randomFact(excluding: autoExplainFact)
            }
        }
    }

    private func stopAutoExplain(clearFact: Bool = true) {
        isAutoExplaining = false
        autoExplainTask?.cancel()
        autoExplainTask = nil
        if clearFact {
            autoExplainFact = nil
        }
    }

    private func randomFact(excluding fact: MathFact?) -> MathFact? {
        let facts = gridData.rowValues.flatMap { row in
            gridData.columnValues.map { column in
                MathFact(a: row, b: column)
            }
        }
        guard !facts.isEmpty else { return nil }
        guard let fact, facts.count > 1 else { return facts.randomElement() }
        var next = fact
        while next == fact {
            if let candidate = facts.randomElement() {
                next = candidate
            }
        }
        return next
    }

    private static func makeGridData(
        guesses: [PracticeGuess],
        operation: OperationType,
        axis: AxisValues
    ) -> GridData {
        let usesStep = operation == .addition || operation == .multiplication
        let stepX = usesStep ? axis.stepX : 1
        let stepY = usesStep ? axis.stepY : 1
        let rowValues = operation.axisValues(minValue: axis.minY, maxValue: axis.maxY, step: stepY)
        let columnValues = operation.axisValues(minValue: axis.minX, maxValue: axis.maxX, step: stepX)
        let rowSet = Set(rowValues)
        let columnSet = Set(columnValues)
        var attempts = 0
        var correct = 0
        var stats: [FactKey: FactStats] = [:]

        for guess in guesses where guess.operation == operation.rawValue {
            guard rowSet.contains(guess.a), columnSet.contains(guess.b) else { continue }
            attempts += 1
            if guess.isCorrect {
                correct += 1
            }
            let key = FactKey(a: guess.a, b: guess.b)
            stats[key, default: FactStats()].add(guess: guess)
        }

        let mastered = stats.values.reduce(into: 0) { count, item in
            if item.isMastered { count += 1 }
        }

        return GridData(
            rowValues: rowValues,
            columnValues: columnValues,
            attempts: attempts,
            correct: correct,
            mastered: mastered,
            statsByFact: stats
        )
    }
}

private struct AxisValues: Equatable {
    let minX: Int
    let maxX: Int
    let minY: Int
    let maxY: Int
    let stepX: Int
    let stepY: Int
}

private struct GridData {
    let rowValues: [Int]
    let columnValues: [Int]
    let attempts: Int
    let correct: Int
    let mastered: Int
    let statsByFact: [FactKey: FactStats]

    static let empty = GridData(
        rowValues: [],
        columnValues: [],
        attempts: 0,
        correct: 0,
        mastered: 0,
        statsByFact: [:]
    )
}

private struct TablePracticeGridHost: View, Equatable {
    let token: Int
    let operation: OperationType
    let rowValues: [Int]
    let columnValues: [Int]
    let statsByFact: [FactKey: FactStats]
    let answersShown: Bool
    let numberStyle: NumberStyle
    let onSelectFact: (MathFact) -> Void

    static func == (lhs: TablePracticeGridHost, rhs: TablePracticeGridHost) -> Bool {
        lhs.token == rhs.token
            && lhs.answersShown == rhs.answersShown
            && lhs.numberStyle == rhs.numberStyle
    }

    var body: some View {
        TablePracticeGridView(
            operation: operation,
            rowValues: rowValues,
            columnValues: columnValues,
            statsByFact: statsByFact,
            answersShown: answersShown,
            numberStyle: numberStyle,
            onSelectFact: onSelectFact
        )
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
