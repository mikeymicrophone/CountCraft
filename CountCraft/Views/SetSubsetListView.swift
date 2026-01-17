//
//  SetSubsetListView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import SwiftUI

struct SetSubsetListView: View {
    let subsets: [[Int]]
    let remainingCount: Int
    let numberStyle: NumberStyle
    let maxHeight: CGFloat

    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(subsets.indices, id: \.self) { index in
                    SetSubsetTileView(values: subsets[index], numberStyle: numberStyle)
                }
                if remainingCount > 0 {
                    SetRemainingTileView(remainingCount: remainingCount, numberStyle: numberStyle)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, maxHeight: maxHeight, alignment: .center)
        .scrollIndicators(.visible)
    }

    private var gridColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 80), spacing: 12)]
    }
}
