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
                Text(numberStyle.attributedNumber(fact.a))
                Text(numberStyle.attributedNumber(fact.b))
                    .font(numberStyle.font(size: 20, weight: .semibold))
                    .baselineOffset(16)
            } else if operation == .sets {
                Text("C(")
                    .foregroundColor(.secondary)
                Text(numberStyle.attributedNumber(fact.b + 1))
                Text(",")
                    .foregroundColor(.secondary)
                Text(numberStyle.attributedNumber(fact.a))
                Text(")")
                    .foregroundColor(.secondary)
            } else {
                Text(numberStyle.attributedNumber(fact.a))
                Text(operation.symbol)
                    .foregroundColor(.primary)
                Text(numberStyle.attributedNumber(fact.b))
            }
            Text("=")
                .foregroundColor(.primary)
            Text("?")
                .foregroundColor(.primary)
        }
        .font(numberStyle.font(size: 34, weight: .semibold))
    }
}
