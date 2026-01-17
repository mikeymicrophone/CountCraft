//
//  TablePracticeControlsView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import SwiftUI

struct TablePracticeControlsView: View {
    @Binding var answersShown: Bool
    @Binding var inputMode: GuessInputMode

    var body: some View {
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
}
