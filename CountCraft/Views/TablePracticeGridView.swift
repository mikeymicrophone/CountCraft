//
//  TablePracticeGridView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import SwiftUI

struct TablePracticeGridView: View {
    let operation: OperationType
    let rowValues: [Int]
    let columnValues: [Int]
    let statsByFact: [FactKey: FactStats]
    let answersShown: Bool
    let numberStyle: NumberStyle
    let onSelectFact: (MathFact) -> Void

    var body: some View {
        ScrollView([.vertical, .horizontal]) {
            LazyVStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    headerCell("")
                    ForEach(columnValues, id: \.self) { value in
                        headerCell(NumberFormatting.string(from: value), value: value)
                    }
                }

                ForEach(rowValues, id: \.self) { row in
                    HStack(spacing: 8) {
                        headerCell(NumberFormatting.string(from: row), value: row)
                        ForEach(columnValues, id: \.self) { column in
                            let fact = MathFact(a: row, b: column)
                            let stats = statsByFact[FactKey(a: row, b: column)]
                            let answer = operation.answer(for: fact)
                            let answerLabel = displayLabel(for: operation, answer: answer)
                            let cellFontSize = fontSize(for: answerLabel)
                            Button {
                                onSelectFact(fact)
                            } label: {
                                FactCell(
                                    label: answersShown ? answerLabel : "?",
                                    status: stats,
                                    isInteractive: !answersShown,
                                    numberFont: numberStyle.font(size: cellFontSize)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func headerCell(_ text: String, value: Int? = nil) -> some View {
        let borderColor = value.flatMap { numberStyle.borderColor(for: $0) }
        return Group {
            if let value {
                Text(numberStyle.attributedNumber(text, value: value))
            } else {
                Text(text)
                    .foregroundColor(.primary)
            }
        }
        .font(numberStyle.font(size: 16))
        .frame(width: 44, height: 44)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .numberBorder(borderColor, cornerRadius: 10)
    }

    private func fontSize(for label: String) -> CGFloat {
        let length = label.count
        if length <= 3 {
            return 16
        }
        if length == 4 {
            return 14
        }
        if length == 5 {
            return 12
        }
        return 10
    }

    private func displayLabel(for operation: OperationType, answer: Int) -> String {
        if operation == .sets, answer == 0 {
            return "∅"
        }
        return NumberFormatting.string(from: answer)
    }
}
