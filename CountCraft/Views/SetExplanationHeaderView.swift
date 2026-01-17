//
//  SetExplanationHeaderView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import SwiftUI

struct SetExplanationHeaderView: View {
    let setSize: Int
    let maxElement: Int
    let totalCount: Int
    let displayLimit: Int
    let numberStyle: NumberStyle

    var body: some View {
        VStack(spacing: 6) {
            Text("Size \(NumberFormatting.string(from: setSize)) subsets of {0...\(NumberFormatting.string(from: maxElement))}")
                .font(numberStyle.font(size: 18, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(formulaText)
                .font(numberStyle.font(size: 16, weight: .semibold))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if totalCount > displayLimit {
                Text("Showing first \(NumberFormatting.string(from: displayLimit)) of \(NumberFormatting.string(from: totalCount))")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var formulaText: String {
        let n = maxElement + 1
        return "C(\(NumberFormatting.string(from: n)), \(NumberFormatting.string(from: setSize))) = \(NumberFormatting.string(from: totalCount))"
    }
}
