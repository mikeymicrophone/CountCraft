//
//  ReviewGuessesView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import SwiftUI

struct ReviewGuessesView: View {
    let guesses: [PracticeGuess]

    @StateObject private var viewModel: ReviewGuessesViewModel

    init(guesses: [PracticeGuess]) {
        self.guesses = guesses
        _viewModel = StateObject(wrappedValue: ReviewGuessesViewModel(guesses: guesses))
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Date", selection: $viewModel.dateFilter) {
                        ForEach(ReviewDateFilter.allCases) { filter in
                            Text(filter.title).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)

                    Picker("Correctness", selection: $viewModel.correctnessFilter) {
                        ForEach(CorrectnessFilter.allCases) { filter in
                            Text(filter.title).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)

                    Toggle("First-time guesses only", isOn: $viewModel.onlyFirstTime)

                    Picker("Most Recent", selection: $viewModel.recentFilter) {
                        ForEach(RecentFilter.allCases) { filter in
                            Text(filter.title).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text("Guesses: \(viewModel.filteredGuesses.count)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                Section {
                    ReviewHeaderRow(
                        rangeA: viewModel.operandMinA...viewModel.operandMaxA,
                        rangeB: viewModel.operandMinB...viewModel.operandMaxB,
                        operationFilter: $viewModel.operationFilter,
                        sortDescriptors: $viewModel.sortDescriptors,
                        onFilterA: { viewModel.activeOperandFilter = .a },
                        onFilterB: { viewModel.activeOperandFilter = .b }
                    )
                    ForEach(viewModel.filteredGuesses) { guess in
                        NavigationLink {
                            PairHistoryView(
                                guesses: viewModel.guesses,
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
            .sheet(item: $viewModel.activeOperandFilter) { filter in
                operandFilterSheet(for: filter)
            }
        }
        .onChange(of: guesses) { _, newValue in
            viewModel.guesses = newValue
        }
    }

    private func operandFilterSheet(for filter: OperandFilter) -> some View {
        NavigationStack {
            VStack(spacing: 20) {
                RangeSlider(
                    label: filter == .a ? "A:" : "B:",
                    lowerValue: filter == .a ? $viewModel.operandMinA : $viewModel.operandMinB,
                    upperValue: filter == .a ? $viewModel.operandMaxA : $viewModel.operandMaxB,
                    bounds: 0...12,
                    onReset: {
                    if filter == .a {
                        viewModel.operandMinA = 0
                        viewModel.operandMaxA = 12
                    } else {
                        viewModel.operandMinB = 0
                        viewModel.operandMaxB = 12
                    }
                },
                    showsTickLabels: true
                )
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle(filter == .a ? "Filter A" : "Filter B")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.activeOperandFilter = nil
                    }
                }
            }
        }
    }
}
