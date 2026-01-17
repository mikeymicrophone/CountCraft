//
//  GuessHintView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import SwiftUI

struct GuessHintView: View {
    let operation: OperationType
    let fact: MathFact
    let numberStyle: NumberStyle

    var body: some View {
        switch operation {
        case .exponent:
            expandedExponentView
        case .multiplication:
            expandedMultiplicationView
        case .addition:
            expandedAdditionView
        }
    }

    private var expandedExponentView: some View {
        let baseText = NumberFormatting.string(from: fact.a)
        let baseColor = numberStyle.secondaryColor(for: fact.a)
        if fact.b == 0 {
            return AnyView(
                VStack(spacing: 4) {
                    Text(baseText)
                        .foregroundColor(baseColor)
                    Rectangle()
                        .frame(width: 40, height: 2)
                        .foregroundColor(.secondary)
                    Text(baseText)
                        .foregroundColor(baseColor)
                }
                .font(numberStyle.font(size: 22, weight: .semibold))
                .foregroundColor(.secondary)
            )
        }

        return AnyView(
            repeatedText(
                value: baseText,
                count: fact.b,
                separator: " x ",
                color: baseColor
            )
            .font(numberStyle.font(size: 22, weight: .semibold))
            .foregroundColor(.secondary)
        )
    }

    private var expandedMultiplicationView: some View {
        let baseText = NumberFormatting.string(from: fact.a)
        let baseColor = numberStyle.secondaryColor(for: fact.a)
        if fact.b <= 0 {
            return AnyView(
                Text("0")
                    .font(numberStyle.font(size: 22, weight: .semibold))
                    .foregroundColor(.secondary)
            )
        }

        return AnyView(
            repeatedText(
                value: baseText,
                count: fact.b,
                separator: " + ",
                color: baseColor
            )
            .font(numberStyle.font(size: 22, weight: .semibold))
            .foregroundColor(.secondary)
        )
    }

    private var expandedAdditionView: some View {
        let left = onesGroup(count: fact.a)
        let right = onesGroup(count: fact.b)
        let oneColor = numberStyle.secondaryColor(for: 1)
        return HStack(spacing: 8) {
            Text(left)
                .foregroundColor(oneColor)
            Text(" ")
                .foregroundColor(.secondary)
            Text(right)
                .foregroundColor(oneColor)
        }
        .font(numberStyle.font(size: 20, weight: .semibold))
        .foregroundColor(.secondary)
    }

    private func onesGroup(count: Int) -> String {
        guard count > 0 else { return "0" }
        return Array(repeating: "1", count: count).joined(separator: " ")
    }

    private func repeatedText(
        value: String,
        count: Int,
        separator: String,
        color: Color
    ) -> Text {
        guard count > 0 else { return Text("0").foregroundColor(.secondary) }
        var text = Text("")
        for index in 0..<count {
            if index > 0 {
                text = text + Text(separator).foregroundColor(.secondary)
            }
            text = text + Text(value).foregroundColor(color)
        }
        return text
    }
}
