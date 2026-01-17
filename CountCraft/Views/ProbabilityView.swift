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
                        title: "At least x sixes after y rolls",
                        rowLabel: "Rows: x (sixes). Columns: y (rolls).",
                        successName: "sixes",
                        trialsName: "rolls",
                        successOutcomes: 1,
                        totalOutcomes: 6,
                        format: format
                    )
                case .coin:
                    ProbabilityGridView(
                        title: "At least x heads after y flips",
                        rowLabel: "Rows: x (heads). Columns: y (flips).",
                        successName: "heads",
                        trialsName: "flips",
                        successOutcomes: 1,
                        totalOutcomes: 2,
                        format: format
                    )
                case .cards:
                    ProbabilityCardsGridView(format: format)
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
