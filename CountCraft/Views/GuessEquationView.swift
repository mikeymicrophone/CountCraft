//
//  GuessEquationView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import SwiftUI

struct GuessEquationView: View {
    let operation: OperationType
    let fact: MathFact
    let numberStyle: NumberStyle

    var body: some View {
        HStack(spacing: 8) {
            if operation == .exponent {
                numberStyle.outlinedNumberText(fact.a)
                numberStyle.outlinedNumberText(fact.b)
                    .font(numberStyle.font(size: 20, weight: .semibold))
                    .baselineOffset(16)
            } else if operation == .sets {
                Text("C(")
                    .foregroundColor(.secondary)
                numberStyle.outlinedNumberText(fact.b + 1)
                Text(",")
                    .foregroundColor(.secondary)
                numberStyle.outlinedNumberText(fact.a)
                Text(")")
                    .foregroundColor(.secondary)
            } else {
                numberStyle.outlinedNumberText(fact.a)
                Text(operation.symbol)
                    .foregroundColor(.primary)
                numberStyle.outlinedNumberText(fact.b)
            }
            Text("=")
                .foregroundColor(.primary)
            Text("?")
                .foregroundColor(.primary)
        }
        .font(numberStyle.font(size: 34, weight: .semibold))
    }
}
