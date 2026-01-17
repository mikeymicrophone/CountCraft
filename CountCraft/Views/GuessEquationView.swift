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
                Text("\(fact.a)")
                    .foregroundColor(numberStyle.primaryColor(for: fact.a))
                Text("\(fact.b)")
                    .font(numberStyle.font(size: 20, weight: .semibold))
                    .baselineOffset(16)
                    .foregroundColor(numberStyle.primaryColor(for: fact.b))
            } else if operation == .sets {
                Text("C(")
                    .foregroundColor(.secondary)
                Text(NumberFormatting.string(from: fact.b + 1))
                    .foregroundColor(numberStyle.primaryColor(for: fact.b + 1))
                Text(",")
                    .foregroundColor(.secondary)
                Text(NumberFormatting.string(from: fact.a))
                    .foregroundColor(numberStyle.primaryColor(for: fact.a))
                Text(")")
                    .foregroundColor(.secondary)
            } else {
                Text("\(fact.a)")
                    .foregroundColor(numberStyle.primaryColor(for: fact.a))
                Text(operation.symbol)
                    .foregroundColor(.primary)
                Text("\(fact.b)")
                    .foregroundColor(numberStyle.primaryColor(for: fact.b))
            }
            Text("=")
                .foregroundColor(.primary)
            Text("?")
                .foregroundColor(.primary)
        }
        .font(numberStyle.font(size: 34, weight: .semibold))
    }
}
