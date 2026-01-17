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

    private let displayLimit = 24

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
        let label = values.isEmpty ? "∅" : values.map { NumberFormatting.string(from: $0) }.joined(separator: ", ")
        return HStack(spacing: 6) {
            if values.isEmpty {
                Text(label)
                    .foregroundColor(.secondary)
            } else {
                ForEach(values, id: \.self) { value in
                    Text(NumberFormatting.string(from: value))
                        .foregroundColor(numberStyle.primaryColor(for: value))
                }
            }
        }
        .font(numberStyle.font(size: 16, weight: .semibold))
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
}
