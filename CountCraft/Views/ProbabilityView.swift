//
//  ProbabilityView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import SwiftUI

struct ProbabilityView: View {
    @State private var mode: ProbabilityMode = .dice
    @State private var format: ProbabilityFormat = .fraction
    @State private var showingPreferences = false
    let onSwitchOperation: ((OperationType, MathFact) -> Void)?

    init(onSwitchOperation: ((OperationType, MathFact) -> Void)? = nil) {
        self.onSwitchOperation = onSwitchOperation
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker("Mode", selection: $mode) {
                    ForEach(ProbabilityMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Format", selection: $format) {
                    ForEach(ProbabilityFormat.allCases) { format in
                        Text(format.title).tag(format)
                    }
                }
                .pickerStyle(.segmented)

                Divider()

                switch mode {
                case .dice:
                    ProbabilityGridView(
                        title: "At least y sixes after x rolls",
                        successName: "sixes",
                        trialsName: "rolls",
                        successOutcomes: 1,
                        totalOutcomes: 6,
                        format: format,
                        onSwitchOperation: onSwitchOperation
                    )
                case .coin:
                    ProbabilityGridView(
                        title: "At least y heads after x flips",
                        successName: "heads",
                        trialsName: "flips",
                        successOutcomes: 1,
                        totalOutcomes: 2,
                        format: format,
                        onSwitchOperation: onSwitchOperation
                    )
                case .cards:
                    ProbabilityCardsGridView(format: format, onSwitchOperation: onSwitchOperation)
                }

                Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle("Probability")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingPreferences = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showingPreferences) {
                PreferencesView()
            }
        }
    }
}
