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
