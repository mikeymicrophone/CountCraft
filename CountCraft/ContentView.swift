//
//  ContentView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PracticeGuess.timestamp, order: .forward) private var guesses: [PracticeGuess]

    var body: some View {
        TabView {
            TablePracticeView(operation: .addition, guesses: guesses, onGuess: recordGuess)
                .tabItem {
                    Label("Addition", systemImage: "plus")
                }

            TablePracticeView(operation: .multiplication, guesses: guesses, onGuess: recordGuess)
                .tabItem {
                    Label("Multiply", systemImage: "multiply")
                }
        }
    }

    private func recordGuess(_ guess: PracticeGuess) {
        withAnimation {
            modelContext.insert(guess)
        }
    }
}

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

struct GuessSheet: View {
    let operation: OperationType
    let fact: MathFact
    let inputMode: GuessInputMode
    let onSubmit: (MathFact, Int?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var entryText = ""
    @State private var options: [Int] = []

    var body: some View {
        VStack(spacing: 16) {
            Text("\(fact.a) \(operation.symbol) \(fact.b) = ?")
                .font(.largeTitle)
                .fontWeight(.semibold)

            switch inputMode {
            case .multipleChoice:
                VStack(spacing: 12) {
                    ForEach(options, id: \.self) { option in
                        Button {
                            submit(answer: option)
                        } label: {
                            Text("\(option)")
                                .font(.title2)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }

            case .freeEntry:
                VStack(spacing: 12) {
                    TextField("Type answer", text: $entryText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)

                    Button("Submit") {
                        let trimmed = entryText.trimmingCharacters(in: .whitespacesAndNewlines)
                        submit(answer: Int(trimmed))
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(Int(entryText.trimmingCharacters(in: .whitespacesAndNewlines)) == nil)
                }
            }
        }
        .padding()
        .onAppear {
            if inputMode == .multipleChoice {
                options = multipleChoiceOptions(for: operation.answer(for: fact))
            }
        }
    }

    private func submit(answer: Int?) {
        onSubmit(fact, answer)
        dismiss()
    }

    private func multipleChoiceOptions(for answer: Int) -> [Int] {
        var values: Set<Int> = [answer]
        while values.count < 4 {
            values.insert(Int.random(in: 0...operation.maxResult))
        }
        return values.shuffled()
    }
}

struct FactCell: View {
    let label: String
    let status: FactStats?
    let isInteractive: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Text(label)
                .font(.headline)
                .frame(width: 44, height: 44)
                .foregroundColor(.primary)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            if let last = status?.lastWasCorrect {
                Image(systemName: last ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.caption2)
                    .foregroundColor(last ? .green : .red)
                    .padding(4)
            }
        }
    }

    private var backgroundColor: Color {
        guard isInteractive else {
            return Color(.secondarySystemBackground)
        }

        if status?.isMastered == true {
            return Color.green.opacity(0.25)
        }
        if status?.lastWasCorrect == false {
            return Color.red.opacity(0.2)
        }
        return Color(.secondarySystemBackground)
    }
}

struct ProgressBadge: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MathFact: Identifiable, Hashable {
    let a: Int
    let b: Int

    var id: String { "\(a)-\(b)" }
}

struct FactKey: Hashable {
    let a: Int
    let b: Int
}

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

private extension OperationType {
    func answer(for fact: MathFact) -> Int {
        switch self {
        case .addition:
            return fact.a + fact.b
        case .multiplication:
            return fact.a * fact.b
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: PracticeGuess.self, inMemory: true)
}
