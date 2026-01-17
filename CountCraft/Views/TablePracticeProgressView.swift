//
//  TablePracticeProgressView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import SwiftUI

struct TablePracticeProgressView: View {
    let attempts: Int
    let correct: Int
    let mastered: Int
    let totalFacts: Int

    private var accuracy: Int {
        guard attempts > 0 else { return 0 }
        return Int((Double(correct) / Double(attempts)) * 100)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Progress")
                .font(.headline)
            HStack(spacing: 16) {
                ProgressBadge(title: "Attempts", value: "\(attempts)")
                ProgressBadge(title: "Accuracy", value: "\(accuracy)%")
                ProgressBadge(title: "Mastered", value: "\(mastered)/\(totalFacts)")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
