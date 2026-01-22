//
//  GuessChoiceListView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import SwiftUI

struct GuessChoiceListView: View {
    let options: [Int]
    let numberStyle: NumberStyle
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ForEach(options, id: \.self) { option in
                Button {
                    onSelect(option)
                } label: {
                    numberStyle.outlinedNumberText(option)
                        .font(numberStyle.font(size: 22, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .numberBorder(numberStyle.borderColor(for: option), cornerRadius: 14)
                }
            }
        }
    }
}
