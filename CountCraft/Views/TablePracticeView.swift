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
    @State private var gridData: GridData
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
        let axis = Self.axisValues(for: operation)
        _gridData = State(
            initialValue: Self.makeGridData(
                guesses: guesses,
                operation: operation,
                axis: axis
            )
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TablePracticeProgressView(
                    attempts: gridData.attempts,
                    correct: gridData.correct,
                    mastered: gridData.statsByFact.values.filter { $0.isMastered }.count,
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
        .onChange(of: axisMinX) { _, _ in
            refreshGridData()
        }
        .onChange(of: axisMaxX) { _, _ in
            refreshGridData()
        }
        .onChange(of: axisMinY) { _, _ in
            refreshGridData()
        }
        .onChange(of: axisMaxY) { _, _ in
            refreshGridData()
        }
        .onChange(of: axisStepX) { _, _ in
            refreshGridData()
        }
        .onChange(of: axisStepY) { _, _ in
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

    private func refreshGridData() {
        let axis = AxisValues(
            minX: axisMinX,
            maxX: axisMaxX,
            minY: axisMinY,
            maxY: axisMaxY,
            stepX: axisStepX,
            stepY: axisStepY
        )
        gridData = Self.makeGridData(guesses: guesses, operation: operation, axis: axis)
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
        activeSheet = TableSheetItem(fact: fact, mode: .explain)
        pendingExplanation = nil
    }

    private static func normalizedRange(minValue: Int, maxValue: Int, step: Int) -> [Int] {
        let lower = min(max(minValue, 0), 40)
        let upper = min(max(maxValue, 0), 40)
        let clampedStep = min(max(step, 1), 10)
        if lower <= upper {
            return Array(stride(from: lower, through: upper, by: clampedStep))
        }
        return Array(stride(from: upper, through: lower, by: clampedStep))
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

    private static func axisValues(for operation: OperationType) -> AxisValues {
        let minXKey = "prefAxisMinX-\(operation.rawValue)"
        let maxXKey = "prefAxisMaxX-\(operation.rawValue)"
        let minYKey = "prefAxisMinY-\(operation.rawValue)"
        let maxYKey = "prefAxisMaxY-\(operation.rawValue)"
        let stepXKey = "prefAxisStepX-\(operation.rawValue)"
        let stepYKey = "prefAxisStepY-\(operation.rawValue)"
        let minX = UserDefaults.standard.integer(forKey: minXKey)
        let maxX = UserDefaults.standard.object(forKey: maxXKey) as? Int ?? 12
        let minY = UserDefaults.standard.integer(forKey: minYKey)
        let maxY = UserDefaults.standard.object(forKey: maxYKey) as? Int ?? 12
        let stepX = UserDefaults.standard.object(forKey: stepXKey) as? Int ?? 1
        let stepY = UserDefaults.standard.object(forKey: stepYKey) as? Int ?? 1
        return AxisValues(minX: minX, maxX: maxX, minY: minY, maxY: maxY, stepX: stepX, stepY: stepY)
    }

    private static func makeGridData(
        guesses: [PracticeGuess],
        operation: OperationType,
        axis: AxisValues
    ) -> GridData {
        let usesStep = operation == .addition || operation == .multiplication
        let stepX = usesStep ? axis.stepX : 1
        let stepY = usesStep ? axis.stepY : 1
        let rowValues = normalizedRange(minValue: axis.minY, maxValue: axis.maxY, step: stepY)
        let columnValues = normalizedRange(minValue: axis.minX, maxValue: axis.maxX, step: stepX)
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
            let current = stats[key] ?? FactStats()
            stats[key] = current.adding(guess: guess)
        }

        return GridData(
            rowValues: rowValues,
            columnValues: columnValues,
            attempts: attempts,
            correct: correct,
            statsByFact: stats
        )
    }
}

private struct AxisValues {
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
    let statsByFact: [FactKey: FactStats]
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
