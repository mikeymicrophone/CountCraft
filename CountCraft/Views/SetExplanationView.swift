//
//  SetExplanationView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import SwiftUI

struct SetExplanationView: View {
    let setSize: Int
    let maxElement: Int
    let numberStyle: NumberStyle

    private let displayLimit = 32

    var body: some View {
        VStack(spacing: 16) {
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

            if totalCount == 0 {
                Text("∅")
                    .font(numberStyle.font(size: 48, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 160, alignment: .center)
            } else if setSize == 0 {
                subsetTile(values: [])
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 12) {
                        ForEach(displayedSubsets.indices, id: \.self) { index in
                            subsetTile(values: displayedSubsets[index])
                        }
                        if remainingCount > 0 {
                            remainingTile
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var formulaText: String {
        let n = maxElement + 1
        return "C(\(NumberFormatting.string(from: n)), \(NumberFormatting.string(from: setSize))) = \(NumberFormatting.string(from: totalCount))"
    }

    private var totalCount: Int {
        Combinatorics.choose(n: maxElement + 1, k: setSize)
    }

    private var displayedSubsets: [[Int]] {
        let elements = Array(0...max(maxElement, 0))
        return Combinatorics.combinations(of: elements, choose: setSize, limit: displayLimit)
    }

    private var remainingCount: Int {
        max(totalCount - displayedSubsets.count, 0)
    }

    private var gridColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 80), spacing: 12)]
    }

    private func subsetTile(values: [Int]) -> some View {
        Text(setText(values: values))
            .font(numberStyle.font(size: tileFontSize(for: values), weight: .semibold))
            .multilineTextAlignment(.center)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .frame(minWidth: 80)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var remainingTile: some View {
        Text("+\(NumberFormatting.string(from: remainingCount))")
            .font(numberStyle.font(size: 16, weight: .semibold))
            .foregroundColor(.secondary)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .frame(minWidth: 80)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func tileFontSize(for values: [Int]) -> CGFloat {
        if values.count <= 4 {
            return 16
        }
        if values.count <= 6 {
            return 14
        }
        return 12
    }

    private func setText(values: [Int]) -> AttributedString {
        var result = AttributedString()
        var open = AttributedString("{")
        open.foregroundColor = .secondary
        result.append(open)

        if !values.isEmpty {
            for (index, value) in values.enumerated() {
                if index > 0 {
                    var comma = AttributedString(", ")
                    comma.foregroundColor = .secondary
                    result.append(comma)
                }
                var valueText = AttributedString(NumberFormatting.string(from: value))
                valueText.foregroundColor = numberStyle.primaryColor(for: value)
                result.append(valueText)
            }
        }

        var close = AttributedString("}")
        close.foregroundColor = .secondary
        result.append(close)
        return result
    }
}
