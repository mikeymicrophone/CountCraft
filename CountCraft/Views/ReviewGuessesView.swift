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
    @State private var operationFilter: OperationFilter = .all
    @State private var operandMinA = 0
    @State private var operandMaxA = 12
    @State private var operandMinB = 0
    @State private var operandMaxB = 12
    @State private var activeOperandFilter: OperandFilter?
    @State private var recentFilter: RecentFilter = .all
    @State private var sortDescriptors: [SortDescriptor] = []

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
        let filtered = sortedGuesses.filter { guess in
            let dateMatch = dateCutoff.map { guess.timestamp >= $0 } ?? true
            let correctnessMatch = correctnessFilter.matches(guess)
            let firstTimeMatch = !onlyFirstTime || firstTimeGuessIds.contains(guess.id)
            let operationMatch = operationFilter.matches(guess)
            let operandMatch = (operandMinA...operandMaxA).contains(guess.a)
                && (operandMinB...operandMaxB).contains(guess.b)
            return dateMatch && correctnessMatch && firstTimeMatch && operationMatch && operandMatch
        }
        let recent = recentFilter.apply(to: filtered)
        return sortDescriptors.isEmpty ? recent : recent.sorted(by: sortComparator)
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

                    Picker("Most Recent", selection: $recentFilter) {
                        ForEach(RecentFilter.allCases) { filter in
                            Text(filter.title).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text("Guesses: \(filteredGuesses.count)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                Section {
                    ReviewHeaderRow(
                        rangeA: operandMinA...operandMaxA,
                        rangeB: operandMinB...operandMaxB,
                        operationFilter: $operationFilter,
                        sortDescriptors: $sortDescriptors,
                        onFilterA: { activeOperandFilter = .a },
                        onFilterB: { activeOperandFilter = .b }
                    )
                    ForEach(filteredGuesses) { guess in
                        NavigationLink {
                            PairHistoryView(
                                guesses: guesses,
                                operation: guess.operation,
                                a: guess.a,
                                b: guess.b
                            )
                        } label: {
                            ReviewGuessRow(guess: guess)
                                .padding(.vertical, 6)
                        }
                    }
                }
            }
            .navigationTitle("Review Guesses")
            .sheet(item: $activeOperandFilter) { filter in
                operandFilterSheet(for: filter)
            }
        }
    }

    private func operandFilterSheet(for filter: OperandFilter) -> some View {
        NavigationStack {
            VStack(spacing: 20) {
                RangeSlider(
                    label: filter == .a ? "A:" : "B:",
                    lowerValue: filter == .a ? $operandMinA : $operandMinB,
                    upperValue: filter == .a ? $operandMaxA : $operandMaxB,
                    bounds: 0...12,
                    showsTickLabels: true
                ) {
                    if filter == .a {
                        operandMinA = 0
                        operandMaxA = 12
                    } else {
                        operandMinB = 0
                        operandMaxB = 12
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle(filter == .a ? "Filter A" : "Filter B")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        activeOperandFilter = nil
                    }
                }
            }
        }
    }

    private func sortComparator(lhs: PracticeGuess, rhs: PracticeGuess) -> Bool {
        for descriptor in sortDescriptors {
            if let result = compare(lhs, rhs, for: descriptor) {
                return result
            }
        }
        return false
    }

    private func compare(_ lhs: PracticeGuess, _ rhs: PracticeGuess, for descriptor: SortDescriptor) -> Bool? {
        let ascending = descriptor.direction == .ascending
        switch descriptor.key {
        case .operandA:
            return compare(lhs.a, rhs.a, ascending: ascending)
        case .operation:
            return compare(lhs.operation, rhs.operation, ascending: ascending)
        case .operandB:
            return compare(lhs.b, rhs.b, ascending: ascending)
        case .guess:
            return compare(lhs.userAnswer ?? Int.min, rhs.userAnswer ?? Int.min, ascending: ascending)
        case .answer:
            return compare(lhs.correctAnswer, rhs.correctAnswer, ascending: ascending)
        case .check:
            return compareBool(lhs.isCorrect, rhs.isCorrect, ascending: ascending)
        case .difficulty:
            return compare(difficultyRank(lhs), difficultyRank(rhs), ascending: ascending)
        case .timestamp:
            return compare(lhs.timestamp, rhs.timestamp, ascending: ascending)
        }
    }

    private func difficultyRank(_ guess: PracticeGuess) -> Int {
        guard let value = guess.difficulty,
              let difficulty = ChoiceDifficulty(rawValue: value) else {
            return 0
        }
        switch difficulty {
        case .easy:
            return 1
        case .medium:
            return 2
        case .hard:
            return 3
        }
    }

    private func compare<T: Comparable>(_ lhs: T, _ rhs: T, ascending: Bool) -> Bool? {
        if lhs == rhs { return nil }
        return ascending ? (lhs < rhs) : (lhs > rhs)
    }

    private func compareBool(_ lhs: Bool, _ rhs: Bool, ascending: Bool) -> Bool? {
        if lhs == rhs { return nil }
        let left = lhs ? 1 : 0
        let right = rhs ? 1 : 0
        return ascending ? (left < right) : (left > right)
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
            return "Week"
        case .lastThirty:
            return "Month"
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

enum OperationFilter: String, CaseIterable, Identifiable {
    case all
    case addition
    case multiplication
    case exponent

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "All"
        case .addition:
            return "Add"
        case .multiplication:
            return "Multiply"
        case .exponent:
            return "Exponent"
        }
    }

    func matches(_ guess: PracticeGuess) -> Bool {
        guard case .all = self else {
            let operation = OperationType(rawValue: guess.operation)
            if self == .addition {
                return operation == .addition
            }
            if self == .multiplication {
                return operation == .multiplication
            }
            return operation == .exponent
        }
        return true
    }

    var symbolLabel: String {
        switch self {
        case .all:
            return "All"
        case .addition:
            return "+"
        case .multiplication:
            return "x"
        case .exponent:
            return "^"
        }
    }
}

struct PairHistoryView: View {
    let guesses: [PracticeGuess]
    let operation: String
    let a: Int
    let b: Int

    private var matchingGuesses: [PracticeGuess] {
        guesses
            .filter { guess in
                guard guess.operation == operation else { return false }
                return (guess.a == a && guess.b == b) || (guess.a == b && guess.b == a)
            }
            .sorted { $0.timestamp > $1.timestamp }
    }

    var body: some View {
        List(matchingGuesses) { guess in
            ReviewGuessRow(guess: guess)
                .padding(.vertical, 6)
        }
        .navigationTitle("\(a) \(operationSymbol) \(b)")
    }

    private var operationSymbol: String {
        OperationType(rawValue: operation)?.symbol ?? "?"
    }
}

struct ReviewHeaderRow: View {
    let rangeA: ClosedRange<Int>
    let rangeB: ClosedRange<Int>
    @Binding var operationFilter: OperationFilter
    @Binding var sortDescriptors: [SortDescriptor]
    let onFilterA: () -> Void
    let onFilterB: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            headerButton(
                title: "A: \(rangeA.lowerBound)-\(rangeA.upperBound)",
                sortKey: .operandA,
                width: ReviewColumns.operand,
                action: onFilterA
            )

            Menu {
                ForEach(OperationFilter.allCases) { filter in
                    Button(filter.title) {
                        operationFilter = filter
                    }
                }
            } label: {
                headerCell(
                    title: operationFilter.symbolLabel,
                    sortKey: .operation,
                    width: ReviewColumns.operatorSymbol,
                    alignment: .center
                )
            }

            headerButton(
                title: "B: \(rangeB.lowerBound)-\(rangeB.upperBound)",
                sortKey: .operandB,
                width: ReviewColumns.operand,
                action: onFilterB
            )

            headerCell(title: "Guess", sortKey: .guess, width: ReviewColumns.guess)
            headerCell(title: "Answer", sortKey: .answer, width: ReviewColumns.answer)
            headerCell(image: Image(systemName: "checkmark.circle.fill"), sortKey: .check, width: ReviewColumns.check)
            headerCell(title: "Difficulty", sortKey: .difficulty, width: ReviewColumns.difficulty)
            headerCell(
                title: "When",
                sortKey: .timestamp,
                width: ReviewColumns.when,
                alignment: .trailing
            )
        }
    }

    private func headerCell(
        title: String,
        sortKey: SortKey? = nil,
        width: CGFloat,
        alignment: Alignment = .leading
    ) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: alignment)
            if let key = sortKey {
                sortButton(for: key)
            }
        }
        .frame(width: width)
    }

    private func headerCell(
        image: Image,
        sortKey: SortKey? = nil,
        width: CGFloat,
        alignment: Alignment = .leading
    ) -> some View {
        HStack(spacing: 4) {
            image
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: alignment)
            if let key = sortKey {
                sortButton(for: key)
            }
        }
        .frame(width: width)
    }

    private func headerButton(
        title: String,
        sortKey: SortKey,
        width: CGFloat,
        action: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 4) {
            Button(action: action) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            sortButton(for: sortKey)
        }
        .frame(width: width)
    }

    private func sortButton(for key: SortKey) -> some View {
        let direction = sortDirection(for: key)
        return Button {
            toggleSort(for: key)
        } label: {
            Image(systemName: direction.iconName)
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: 14, height: 14, alignment: .center)
        }
        .buttonStyle(.plain)
    }

    private func sortDirection(for key: SortKey) -> SortDirection {
        sortDescriptors.first(where: { $0.key == key })?.direction ?? .none
    }

    private func toggleSort(for key: SortKey) {
        if let index = sortDescriptors.firstIndex(where: { $0.key == key }) {
            let next = sortDescriptors[index].direction.next
            if next == .none {
                sortDescriptors.remove(at: index)
            } else {
                sortDescriptors[index].direction = next
                let updated = sortDescriptors.remove(at: index)
                sortDescriptors.append(updated)
            }
        } else {
            sortDescriptors.append(SortDescriptor(key: key, direction: .ascending))
        }
    }
}

struct ReviewGuessRow: View {
    let guess: PracticeGuess
    @AppStorage("prefColorCodedNumbers") private var colorCodedNumbers = false

    var body: some View {
        HStack(spacing: 12) {
            Text(NumberFormatting.string(from: guess.a))
                .foregroundColor(numberColor(for: guess.a) ?? .primary)
                .frame(width: ReviewColumns.operand, alignment: .leading)

            Text(operationSymbol)
                .foregroundColor(.secondary)
                .frame(width: ReviewColumns.operatorSymbol, alignment: .center)

            Text(NumberFormatting.string(from: guess.b))
                .foregroundColor(numberColor(for: guess.b) ?? .primary)
                .frame(width: ReviewColumns.operand, alignment: .leading)

            Text(guessAnswerText)
                .foregroundColor(guessAnswerColor)
                .frame(width: ReviewColumns.guess, alignment: .leading)

            Text(NumberFormatting.string(from: guess.correctAnswer))
                .foregroundColor(numberColor(for: guess.correctAnswer) ?? .primary)
                .frame(width: ReviewColumns.answer, alignment: .leading)

            Image(systemName: guess.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(guess.isCorrect ? .green : .red)
                .frame(width: ReviewColumns.check, alignment: .leading)

            Text(difficultyText)
                .frame(width: ReviewColumns.difficulty, alignment: .leading)

            Text(guess.timestamp, style: .relative)
                .foregroundColor(.secondary)
                .frame(width: ReviewColumns.when, alignment: .trailing)
        }
        .font(.subheadline)
    }

    private var guessAnswerText: String {
        guard let answer = guess.userAnswer else { return "—" }
        return NumberFormatting.string(from: answer)
    }

    private var difficultyText: String {
        guard let value = guess.difficulty,
              let difficulty = ChoiceDifficulty(rawValue: value) else {
            return "Unknown"
        }
        return difficulty.title
    }

    private var operationSymbol: String {
        OperationType(rawValue: guess.operation)?.symbol ?? "?"
    }

    private func numberColor(for value: Int) -> Color? {
        NumberStyling.color(for: value, enabled: colorCodedNumbers)
    }

    private var guessAnswerColor: Color {
        guard let answer = guess.userAnswer else { return .secondary }
        return numberColor(for: answer) ?? .primary
    }
}

enum OperandFilter: String, Identifiable {
    case a
    case b

    var id: String { rawValue }
}

private enum ReviewColumns {
    static let operand: CGFloat = 72
    static let operatorSymbol: CGFloat = 28
    static let guess: CGFloat = 64
    static let answer: CGFloat = 64
    static let check: CGFloat = 26
    static let difficulty: CGFloat = 74
    static let when: CGFloat = 70
}

enum RecentFilter: String, CaseIterable, Identifiable {
    case all
    case last10
    case last25
    case last50

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "All"
        case .last10:
            return "10"
        case .last25:
            return "25"
        case .last50:
            return "50"
        }
    }

    func apply(to guesses: [PracticeGuess]) -> [PracticeGuess] {
        switch self {
        case .all:
            return guesses
        case .last10:
            return Array(guesses.prefix(10))
        case .last25:
            return Array(guesses.prefix(25))
        case .last50:
            return Array(guesses.prefix(50))
        }
    }
}

enum SortKey: String, CaseIterable, Identifiable {
    case operandA
    case operation
    case operandB
    case guess
    case answer
    case check
    case difficulty
    case timestamp

    var id: String { rawValue }
}

enum SortDirection: String {
    case none
    case ascending
    case descending

    var next: SortDirection {
        switch self {
        case .none:
            return .ascending
        case .ascending:
            return .descending
        case .descending:
            return .none
        }
    }

    var iconName: String {
        switch self {
        case .none:
            return "arrow.up.arrow.down"
        case .ascending:
            return "arrow.up"
        case .descending:
            return "arrow.down"
        }
    }
}

struct SortDescriptor: Identifiable {
    let key: SortKey
    var direction: SortDirection

    var id: String { key.rawValue }
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

