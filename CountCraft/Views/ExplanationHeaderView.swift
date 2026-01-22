//
//  ExplanationHeaderView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import SwiftUI

struct ExplanationHeaderView: View {
    let operation: OperationType
    let fact: MathFact
    let numberStyle: NumberStyle

    var body: some View {
        if operation == .exponent {
            HStack(spacing: 6) {
                exponentSuperscriptText(
                    base: fact.a,
                    exponent: fact.b,
                    baseSize: 28,
                    exponentSize: 18,
                    exponentOffset: 12
                )
                Text("=")
                    .foregroundColor(.secondary)
                    .font(numberStyle.font(size: 28, weight: .semibold))
                Text(numberStyle.attributedNumber(operation.answer(for: fact)))
                    .font(numberStyle.font(size: 28, weight: .semibold))
            }
        } else if operation == .sets {
            HStack(spacing: 4) {
                Text("C(")
                    .foregroundColor(.secondary)
                Text(numberStyle.attributedNumber(fact.b + 1))
                Text(",")
                    .foregroundColor(.secondary)
                Text(numberStyle.attributedNumber(fact.a))
                Text(") =")
                    .foregroundColor(.secondary)
                Text(numberStyle.attributedNumber(operation.answer(for: fact)))
            }
            .font(numberStyle.font(size: 26, weight: .semibold))
        } else {
            HStack(spacing: 8) {
                Text(numberStyle.attributedNumber(fact.a))
                Text(operation.symbol)
                    .foregroundColor(.secondary)
                Text(numberStyle.attributedNumber(fact.b))
                Text("=")
                    .foregroundColor(.secondary)
                Text(numberStyle.attributedNumber(operation.answer(for: fact)))
            }
            .font(numberStyle.font(size: 28, weight: .semibold))
        }
    }

    private func exponentSuperscriptText(
        base: Int,
        exponent: Int,
        baseSize: CGFloat,
        exponentSize: CGFloat,
        exponentOffset: CGFloat
    ) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text(numberStyle.attributedNumber(base))
                .font(numberStyle.font(size: baseSize, weight: .semibold))
            Text(numberStyle.attributedNumber(exponent))
                .font(numberStyle.font(size: exponentSize, weight: .semibold))
                .baselineOffset(exponentOffset)
        }
    }
}
