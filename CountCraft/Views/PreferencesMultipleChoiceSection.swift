//
//  PreferencesMultipleChoiceSection.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import SwiftUI

struct PreferencesMultipleChoiceSection: View {
    @Binding var difficultyRaw: String
    let description: String

    var body: some View {
        Section("Multiple Choice") {
            Picker("Challenge Level", selection: $difficultyRaw) {
                ForEach(ChoiceDifficulty.allCases) { difficulty in
                    Text(difficulty.title).tag(difficulty.rawValue)
                }
            }
            .pickerStyle(.segmented)

            Text(description)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}
