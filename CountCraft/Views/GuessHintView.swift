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
        case .sets:
            EmptyView()
        }
    }

    private var expandedExponentView: some View {
        let baseText = NumberFormatting.string(from: fact.a)
        if fact.b == 0 {
            return AnyView(
                VStack(spacing: 4) {
                    Text(numberStyle.attributedNumber(baseText, value: fact.a, role: .secondary))
                    Rectangle()
                        .frame(width: 40, height: 2)
                        .foregroundColor(.secondary)
                    Text(numberStyle.attributedNumber(baseText, value: fact.a, role: .secondary))
                }
                .font(numberStyle.font(size: 22, weight: .semibold))
            )
        }

        return AnyView(
            repeatedText(
                valueText: baseText,
                value: fact.a,
                count: fact.b,
                separator: " x ",
                role: .secondary
            )
            .font(numberStyle.font(size: 22, weight: .semibold))
        )
    }

    private var expandedMultiplicationView: some View {
        let baseText = NumberFormatting.string(from: fact.a)
        if fact.b <= 0 {
            return AnyView(
                Text("0")
                    .font(numberStyle.font(size: 22, weight: .semibold))
                    .foregroundColor(.secondary)
            )
        }

        return AnyView(
            repeatedText(
                valueText: baseText,
                value: fact.a,
                count: fact.b,
                separator: " + ",
                role: .secondary
            )
            .font(numberStyle.font(size: 22, weight: .semibold))
        )
    }

    private var expandedAdditionView: some View {
        let left = onesGroup(count: fact.a)
        let right = onesGroup(count: fact.b)
        return HStack(spacing: 8) {
            Text(numberStyle.attributedNumber(left, value: 1, role: .secondary))
            Text(" ")
                .foregroundColor(.secondary)
            Text(numberStyle.attributedNumber(right, value: 1, role: .secondary))
        }
        .font(numberStyle.font(size: 20, weight: .semibold))
    }

    private func onesGroup(count: Int) -> String {
        guard count > 0 else { return "0" }
        return Array(repeating: "1", count: count).joined(separator: " ")
    }

    private func repeatedText(
        valueText: String,
        value: Int,
        count: Int,
        separator: String,
        role: NumberStyle.Role
    ) -> Text {
        guard count > 0 else { return Text("0").foregroundColor(.secondary) }
        var result = AttributedString()
        for index in 0..<count {
            if index > 0 {
                var separatorText = AttributedString(separator)
                separatorText.foregroundColor = .secondary
                result.append(separatorText)
            }
            let valueAttributed = numberStyle.attributedNumber(valueText, value: value, role: role)
            result.append(valueAttributed)
        }
        return Text(result)
    }
}
