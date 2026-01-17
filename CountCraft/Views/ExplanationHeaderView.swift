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
                    exponentOffset: 12,
                    baseColor: numberStyle.primaryColor(for: fact.a),
                    exponentColor: numberStyle.primaryColor(for: fact.b)
                )
                Text("=")
                    .foregroundColor(.secondary)
                    .font(numberStyle.font(size: 28, weight: .semibold))
                Text(NumberFormatting.string(from: operation.answer(for: fact)))
                    .foregroundColor(numberStyle.primaryColor(for: operation.answer(for: fact)))
                    .font(numberStyle.font(size: 28, weight: .semibold))
            }
        } else {
            HStack(spacing: 8) {
                Text(NumberFormatting.string(from: fact.a))
                    .foregroundColor(numberStyle.primaryColor(for: fact.a))
                Text(operation.symbol)
                    .foregroundColor(.secondary)
                Text(NumberFormatting.string(from: fact.b))
                    .foregroundColor(numberStyle.primaryColor(for: fact.b))
                Text("=")
                    .foregroundColor(.secondary)
                Text(NumberFormatting.string(from: operation.answer(for: fact)))
                    .foregroundColor(numberStyle.primaryColor(for: operation.answer(for: fact)))
            }
            .font(numberStyle.font(size: 28, weight: .semibold))
        }
    }

    private func exponentSuperscriptText(
        base: Int,
        exponent: Int,
        baseSize: CGFloat,
        exponentSize: CGFloat,
        exponentOffset: CGFloat,
        baseColor: Color,
        exponentColor: Color
    ) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text(NumberFormatting.string(from: base))
                .foregroundColor(baseColor)
                .font(numberStyle.font(size: baseSize, weight: .semibold))
            Text(NumberFormatting.string(from: exponent))
                .foregroundColor(exponentColor)
                .font(numberStyle.font(size: exponentSize, weight: .semibold))
                .baselineOffset(exponentOffset)
        }
    }
}
