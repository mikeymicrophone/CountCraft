//
//  ExplanationOperationArrows.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import SwiftUI

struct ExplanationOperationArrows: View {
    let currentOperation: OperationType
    let onSelect: (OperationType) -> Void

    var body: some View {
        HStack(spacing: 24) {
            if currentOperation == .multiplication {
                arrowButton(systemName: "arrow.left", target: .addition)
                arrowButton(systemName: "arrow.right", target: .exponent)
            } else if currentOperation == .addition {
                arrowButton(systemName: "arrow.right", target: .multiplication)
            } else {
                arrowButton(systemName: "arrow.left", target: .multiplication)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func arrowButton(systemName: String, target: OperationType) -> some View {
        Button {
            onSelect(target)
        } label: {
            Image(systemName: systemName)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(8)
                .background(Color(.systemBackground))
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}
