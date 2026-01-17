//
//  ExplanationNavigationArrows.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import SwiftUI

struct ExplanationNavigationArrows: View {
    let operation: OperationType
    let fact: MathFact
    let rowValues: [Int]
    let columnValues: [Int]
    let onNavigate: (MathFact) -> Void
    let onSwitchOperation: ((OperationType) -> Void)?

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let topY: CGFloat = 16
            let operationOffset: CGFloat = 40
            ZStack {
                arrowButton(
                    systemName: "arrow.up.left",
                    enabled: canMove(rowDelta: -1, colDelta: -1)
                ) {
                    move(rowDelta: -1, colDelta: -1)
                }
                .position(x: 24, y: topY)

                arrowButton(
                    systemName: "arrow.up.right",
                    enabled: canMove(rowDelta: -1, colDelta: 1)
                ) {
                    move(rowDelta: -1, colDelta: 1)
                }
                .position(x: width - 24, y: topY)

                arrowButton(
                    systemName: "arrow.up",
                    enabled: canMove(rowDelta: -1, colDelta: 0)
                ) {
                    move(rowDelta: -1, colDelta: 0)
                }
                .position(x: width / 2, y: topY)

                if let target = switchLeftTarget {
                    arrowButton(
                        systemName: "arrow.left",
                        enabled: onSwitchOperation != nil
                    ) {
                        onSwitchOperation?(target)
                    }
                    .position(x: width / 2 - operationOffset, y: topY)
                }

                if let target = switchRightTarget {
                    arrowButton(
                        systemName: "arrow.right",
                        enabled: onSwitchOperation != nil
                    ) {
                        onSwitchOperation?(target)
                    }
                    .position(x: width / 2 + operationOffset, y: topY)
                }

                arrowButton(
                    systemName: "arrow.down",
                    enabled: canMove(rowDelta: 1, colDelta: 0)
                ) {
                    move(rowDelta: 1, colDelta: 0)
                }
                .position(x: width / 2, y: height - 8)

                arrowButton(
                    systemName: "arrow.down.left",
                    enabled: canMove(rowDelta: 1, colDelta: -1)
                ) {
                    move(rowDelta: 1, colDelta: -1)
                }
                .position(x: 24, y: height - 24)

                arrowButton(
                    systemName: "arrow.down.right",
                    enabled: canMove(rowDelta: 1, colDelta: 1)
                ) {
                    move(rowDelta: 1, colDelta: 1)
                }
                .position(x: width - 24, y: height - 24)

                arrowButton(
                    systemName: "arrow.left",
                    enabled: canMove(rowDelta: 0, colDelta: -1)
                ) {
                    move(rowDelta: 0, colDelta: -1)
                }
                .position(x: 8, y: height / 2)

                arrowButton(
                    systemName: "arrow.right",
                    enabled: canMove(rowDelta: 0, colDelta: 1)
                ) {
                    move(rowDelta: 0, colDelta: 1)
                }
                .position(x: width - 8, y: height / 2)
            }
        }
    }

    private func arrowButton(
        systemName: String,
        enabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.headline)
                .foregroundColor(enabled ? .secondary : Color.secondary.opacity(0.35))
                .padding(8)
                .background(Color(.systemBackground))
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }

    private func canMove(rowDelta: Int, colDelta: Int) -> Bool {
        guard let rowIndex = rowValues.firstIndex(of: fact.a),
              let colIndex = columnValues.firstIndex(of: fact.b) else {
            return false
        }
        let targetRow = rowIndex + rowDelta
        let targetCol = colIndex + colDelta
        return rowValues.indices.contains(targetRow) && columnValues.indices.contains(targetCol)
    }

    private func move(rowDelta: Int, colDelta: Int) {
        guard let rowIndex = rowValues.firstIndex(of: fact.a),
              let colIndex = columnValues.firstIndex(of: fact.b) else {
            return
        }
        let targetRow = rowIndex + rowDelta
        let targetCol = colIndex + colDelta
        guard rowValues.indices.contains(targetRow), columnValues.indices.contains(targetCol) else { return }
        let next = MathFact(a: rowValues[targetRow], b: columnValues[targetCol])
        onNavigate(next)
    }

    private var switchLeftTarget: OperationType? {
        switch operation {
        case .addition:
            return nil
        case .multiplication:
            return .addition
        case .exponent:
            return .multiplication
        case .sets:
            return .exponent
        }
    }

    private var switchRightTarget: OperationType? {
        switch operation {
        case .addition:
            return .multiplication
        case .multiplication:
            return .exponent
        case .exponent:
            return .sets
        case .sets:
            return nil
        }
    }
}
