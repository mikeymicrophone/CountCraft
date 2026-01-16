//
//  PreferencesView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import SwiftUI

struct PreferencesView: View {
    @AppStorage("prefColorCodedNumbers") private var colorCodedNumbers = false
    @AppStorage("prefNumberFont") private var numberFontRaw = NumberFontChoice.rounded.rawValue
    @AppStorage("prefChoiceDifficulty") private var difficultyRaw = ChoiceDifficulty.medium.rawValue
    @AppStorage("prefAxisMinX") private var axisMinX = 0
    @AppStorage("prefAxisMaxX") private var axisMaxX = 12
    @AppStorage("prefAxisMinY") private var axisMinY = 0
    @AppStorage("prefAxisMaxY") private var axisMaxY = 12

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Numbers") {
                    Toggle("Color-code 0–12", isOn: $colorCodedNumbers)

                    Picker("Number Font", selection: $numberFontRaw) {
                        ForEach(NumberFontChoice.allCases) { choice in
                            Text(choice.title).tag(choice.rawValue)
                        }
                    }
                }

                Section("Multiple Choice") {
                    Picker("Challenge Level", selection: $difficultyRaw) {
                        ForEach(ChoiceDifficulty.allCases) { difficulty in
                            Text(difficulty.title).tag(difficulty.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text(difficultyDescription)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                Section("Table Range") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("X Axis (top)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Stepper("Min: \(axisMinX)", value: $axisMinX, in: 0...12)
                            .onChange(of: axisMinX) { _, newValue in
                                if newValue > axisMaxX {
                                    axisMaxX = newValue
                                }
                            }
                        Stepper("Max: \(axisMaxX)", value: $axisMaxX, in: 0...12)
                            .onChange(of: axisMaxX) { _, newValue in
                                if newValue < axisMinX {
                                    axisMinX = newValue
                                }
                            }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Y Axis (side)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Stepper("Min: \(axisMinY)", value: $axisMinY, in: 0...12)
                            .onChange(of: axisMinY) { _, newValue in
                                if newValue > axisMaxY {
                                    axisMaxY = newValue
                                }
                            }
                        Stepper("Max: \(axisMaxY)", value: $axisMaxY, in: 0...12)
                            .onChange(of: axisMaxY) { _, newValue in
                                if newValue < axisMinY {
                                    axisMinY = newValue
                                }
                            }
                    }
                }
            }
            .navigationTitle("Preferences")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var difficultyDescription: String {
        let choice = ChoiceDifficulty(rawValue: difficultyRaw) ?? .medium
        switch choice {
        case .easy:
            return "Distractors stay further from the correct answer."
        case .medium:
            return "Distractors mix near and mid-range values."
        case .hard:
            return "Distractors cluster close to the correct answer."
        }
    }
}
