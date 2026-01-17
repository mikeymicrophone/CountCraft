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
    let numberFont: (CGFloat, Font.Weight) -> Font
    let numberColor: (Int) -> Color?

    var body: some View {
        if operation == .exponent {
            HStack(spacing: 6) {
                exponentSuperscriptText(
                    base: fact.a,
                    exponent: fact.b,
                    baseSize: 28,
                    exponentSize: 18,
                    exponentOffset: 12,
                    baseColor: numberColor(fact.a) ?? .primary,
                    exponentColor: numberColor(fact.b) ?? .primary
                )
                Text("=")
                    .foregroundColor(.secondary)
                    .font(numberFont(28, .semibold))
                Text(NumberFormatting.string(from: operation.answer(for: fact)))
                    .foregroundColor(numberColor(operation.answer(for: fact)) ?? .primary)
                    .font(numberFont(28, .semibold))
            }
        } else {
            HStack(spacing: 8) {
                Text(NumberFormatting.string(from: fact.a))
                    .foregroundColor(numberColor(fact.a) ?? .primary)
                Text(operation.symbol)
                    .foregroundColor(.secondary)
                Text(NumberFormatting.string(from: fact.b))
                    .foregroundColor(numberColor(fact.b) ?? .primary)
                Text("=")
                    .foregroundColor(.secondary)
                Text(NumberFormatting.string(from: operation.answer(for: fact)))
                    .foregroundColor(numberColor(operation.answer(for: fact)) ?? .primary)
            }
            .font(numberFont(28, .semibold))
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
                .font(numberFont(baseSize, .semibold))
            Text(NumberFormatting.string(from: exponent))
                .foregroundColor(exponentColor)
                .font(numberFont(exponentSize, .semibold))
                .baselineOffset(exponentOffset)
        }
    }
}
