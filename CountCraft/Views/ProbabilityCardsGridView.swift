//
//  ProbabilityCardsGridView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import SwiftUI

struct ProbabilityCardsGridView: View {
    let format: ProbabilityFormat
    @State private var focus: CardFocus = .face

    var body: some View {
        VStack(spacing: 12) {
            Picker("Card Focus", selection: $focus) {
                ForEach(CardFocus.allCases) { focus in
                    Text(focus.title).tag(focus)
                }
            }
            .pickerStyle(.segmented)

            ProbabilityGridView(
                title: "At least y \(focus.rowLabel) after x pulls",
                successName: focus.rowLabel,
                trialsName: "pulls",
                successOutcomes: focus.successOutcomes,
                totalOutcomes: 52,
                format: format
            )
        }
    }
}
