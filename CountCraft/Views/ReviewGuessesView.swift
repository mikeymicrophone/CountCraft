//
//  ReviewGuessesView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import SwiftUI

struct ReviewGuessesView: View {
    let guesses: [PracticeGuess]

    @State private var dateFilter: ReviewDateFilter = .all
    @State private var correctnessFilter: CorrectnessFilter = .all
    @State private var onlyFirstTime = false

    private var sortedGuesses: [PracticeGuess] {
        guesses.sorted { $0.timestamp > $1.timestamp }
    }

    private var firstTimeGuessIds: Set<UUID> {
        var earliest: [FactKey: PracticeGuess] = [:]
        for guess in guesses {
            let key = FactKey(a: guess.a, b: guess.b)
            if let current = earliest[key] {
                if guess.timestamp < current.timestamp {
                    earliest[key] = guess
                }
            } else {
                earliest[key] = guess
            }
        }
        return Set(earliest.values.map(\.id))
    }

    private var filteredGuesses: [PracticeGuess] {
        let dateCutoff = dateFilter.cutoffDate
        return sortedGuesses.filter { guess in
            let dateMatch = dateCutoff.map { guess.timestamp >= $0 } ?? true
            let correctnessMatch = correctnessFilter.matches(guess)
            let firstTimeMatch = !onlyFirstTime || firstTimeGuessIds.contains(guess.id)
            return dateMatch && correctnessMatch && firstTimeMatch
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Date", selection: $dateFilter) {
                        ForEach(ReviewDateFilter.allCases) { filter in
                            Text(filter.title).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)

                    Picker("Correctness", selection: $correctnessFilter) {
                        ForEach(CorrectnessFilter.allCases) { filter in
                            Text(filter.title).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)

                    Toggle("First-time guesses only", isOn: $onlyFirstTime)
                }

                Section {
                    ForEach(filteredGuesses) { guess in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(guess.titleLine)
                                .font(.headline)

                            Text(guess.detailLine)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            HStack(spacing: 8) {
                                Text(guess.isCorrect ? "Correct" : "Missed")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(guess.isCorrect ? .green : .red)

                                Text(guess.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("Review Guesses")
        }
    }
}

enum ReviewDateFilter: String, CaseIterable, Identifiable {
    case all
    case today
    case lastSeven
    case lastThirty

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "All"
        case .today:
            return "Today"
        case .lastSeven:
            return "7d"
        case .lastThirty:
            return "30d"
        }
    }

    var cutoffDate: Date? {
        let calendar = Calendar.current
        switch self {
        case .all:
            return nil
        case .today:
            return calendar.startOfDay(for: Date())
        case .lastSeven:
            return calendar.date(byAdding: .day, value: -7, to: Date())
        case .lastThirty:
            return calendar.date(byAdding: .day, value: -30, to: Date())
        }
    }
}

enum CorrectnessFilter: String, CaseIterable, Identifiable {
    case all
    case correct
    case incorrect

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "All"
        case .correct:
            return "Correct"
        case .incorrect:
            return "Missed"
        }
    }

    func matches(_ guess: PracticeGuess) -> Bool {
        switch self {
        case .all:
            return true
        case .correct:
            return guess.isCorrect
        case .incorrect:
            return !guess.isCorrect
        }
    }
}

private extension PracticeGuess {
    var operationSymbol: String {
        OperationType(rawValue: operation)?.symbol ?? "?"
    }

    var titleLine: String {
        "\(a) \(operationSymbol) \(b) = \(correctAnswer)"
    }

    var detailLine: String {
        let answerText = userAnswer.map(String.init) ?? "No answer"
        let difficultyText = difficulty.flatMap { ChoiceDifficulty(rawValue: $0)?.title } ?? "Unknown"
        return "Your answer: \(answerText) • \(inputModeText) • \(difficultyText)"
    }

    var inputModeText: String {
        GuessInputMode(rawValue: inputMode)?.title ?? "Unknown mode"
    }
}
