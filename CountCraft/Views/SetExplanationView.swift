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

    private let listMaxHeight: CGFloat = 300

    var body: some View {
        VStack(spacing: 16) {
            SetExplanationHeaderView(
                setSize: setSize,
                maxElement: maxElement,
                totalCount: totalCount,
                displayLimit: displayLimit,
                numberStyle: numberStyle
            )

            if totalCount == 0 {
                Text("∅")
                    .font(numberStyle.font(size: 48, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 160, alignment: .center)
            } else if setSize == 0 {
                SetSubsetTileView(values: [], numberStyle: numberStyle)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                SetSubsetListView(
                    subsets: displayedSubsets,
                    remainingCount: remainingCount,
                    numberStyle: numberStyle,
                    maxHeight: listMaxHeight
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var totalCount: Int {
        Combinatorics.choose(n: maxElement + 1, k: setSize)
    }

    private var displayLimit: Int {
        let maxDisplay = 600
        return min(totalCount, maxDisplay)
    }

    private var displayedSubsets: [[Int]] {
        let elements = Array(0...max(maxElement, 0))
        return Combinatorics.combinations(of: elements, choose: setSize, limit: displayLimit)
    }

    private var remainingCount: Int {
        max(totalCount - displayedSubsets.count, 0)
    }
}
