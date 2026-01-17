//
//  PreferencesNumbersSection.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import SwiftUI

struct PreferencesNumbersSection: View {
    @Binding var colorCodedNumbers: Bool
    @Binding var hintsShown: Bool
    @Binding var numberFontRaw: String

    var body: some View {
        Section("Numbers") {
            Toggle("Color-code 0-12", isOn: $colorCodedNumbers)
            Toggle("Hints Shown", isOn: $hintsShown)

            Picker("Number Font", selection: $numberFontRaw) {
                ForEach(NumberFontChoice.allCases) { choice in
                    Text(choice.title).tag(choice.rawValue)
                }
            }
        }
    }
}
