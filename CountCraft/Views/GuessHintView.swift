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
                    numberStyle.outlinedNumberText(baseText, value: fact.a, role: .secondary)
                    Rectangle()
                        .frame(width: 40, height: 2)
                        .foregroundColor(.secondary)
                    numberStyle.outlinedNumberText(baseText, value: fact.a, role: .secondary)
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
            numberStyle.outlinedNumberText(left, value: 1, role: .secondary)
            Text(" ")
                .foregroundColor(.secondary)
            numberStyle.outlinedNumberText(right, value: 1, role: .secondary)
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
    ) -> AnyView {
        if count <= 0 {
            return AnyView(
                Text("0")
                    .foregroundColor(.secondary)
            )
        }

        var fill = AttributedString()
        var inner = AttributedString()
        var outer = AttributedString()
        var hasInner = false
        var hasOuter = false

        for index in 0..<count {
            if index > 0 {
                var separatorText = AttributedString(separator)
                separatorText.foregroundColor = .secondary
                fill.append(separatorText)

                appendClear(separator, to: &inner)
                appendClear(separator, to: &outer)
            }
            fill.append(numberStyle.fillAttributedString(valueText, value: value, role: role))
            if let innerSegment = numberStyle.innerOutlineAttributedString(valueText, value: value, role: role) {
                inner.append(innerSegment)
                hasInner = true
            } else {
                appendClear(valueText, to: &inner)
            }
            if let outerSegment = numberStyle.outerOutlineAttributedString(valueText, value: value, role: role) {
                outer.append(outerSegment)
                hasOuter = true
            } else {
                appendClear(valueText, to: &outer)
            }
        }

        if hasInner || hasOuter {
            return AnyView(
                numberStyle.outlinedAttributedText(
                    fill: fill,
                    innerOutline: hasInner ? inner : nil,
                    outerOutline: hasOuter ? outer : nil
                )
            )
        }
        return AnyView(Text(fill))
    }

    private func appendClear(_ text: String, to attributed: inout AttributedString) {
        var clearText = AttributedString(text)
        clearText.foregroundColor = .clear
        attributed.append(clearText)
    }
}
