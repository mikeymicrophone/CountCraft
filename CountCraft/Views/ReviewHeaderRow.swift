//
//  ReviewHeaderRow.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import SwiftUI

struct ReviewHeaderRow: View {
    let rangeA: ClosedRange<Int>
    let rangeB: ClosedRange<Int>
    @Binding var operationFilter: OperationFilter
    @Binding var sortDescriptors: [SortDescriptor]
    let onFilterA: () -> Void
    let onFilterB: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            headerButton(
                title: "A: \(rangeA.lowerBound)-\(rangeA.upperBound)",
                sortKey: .operandA,
                width: ReviewColumns.operand,
                action: onFilterA
            )

            Menu {
                ForEach(OperationFilter.allCases) { filter in
                    Button(filter.title) {
                        operationFilter = filter
                    }
                }
            } label: {
                headerCell(
                    title: operationFilter.symbolLabel,
                    sortKey: .operation,
                    width: ReviewColumns.operatorSymbol,
                    alignment: .center
                )
            }

            headerButton(
                title: "B: \(rangeB.lowerBound)-\(rangeB.upperBound)",
                sortKey: .operandB,
                width: ReviewColumns.operand,
                action: onFilterB
            )

            headerCell(title: "Guess", sortKey: .guess, width: ReviewColumns.guess)
            headerCell(title: "Answer", sortKey: .answer, width: ReviewColumns.answer)
            headerCell(image: Image(systemName: "checkmark.circle.fill"), sortKey: .check, width: ReviewColumns.check)
            headerCell(title: "Difficulty", sortKey: .difficulty, width: ReviewColumns.difficulty)
            headerCell(
                title: "When",
                sortKey: .timestamp,
                width: ReviewColumns.when,
                alignment: .trailing
            )
        }
    }

    private func headerCell(
        title: String,
        sortKey: SortKey? = nil,
        width: CGFloat,
        alignment: Alignment = .leading
    ) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: alignment)
            if let key = sortKey {
                sortButton(for: key)
            }
        }
        .frame(width: width)
    }

    private func headerCell(
        image: Image,
        sortKey: SortKey? = nil,
        width: CGFloat,
        alignment: Alignment = .leading
    ) -> some View {
        HStack(spacing: 4) {
            image
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: alignment)
            if let key = sortKey {
                sortButton(for: key)
            }
        }
        .frame(width: width)
    }

    private func headerButton(
        title: String,
        sortKey: SortKey,
        width: CGFloat,
        action: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 4) {
            Button(action: action) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            sortButton(for: sortKey)
        }
        .frame(width: width)
    }

    private func sortButton(for key: SortKey) -> some View {
        let direction = sortDirection(for: key)
        return Button {
            toggleSort(for: key)
        } label: {
            Image(systemName: direction.iconName)
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: 14, height: 14, alignment: .center)
        }
        .buttonStyle(.plain)
    }

    private func sortDirection(for key: SortKey) -> SortDirection {
        sortDescriptors.first(where: { $0.key == key })?.direction ?? .none
    }

    private func toggleSort(for key: SortKey) {
        if let index = sortDescriptors.firstIndex(where: { $0.key == key }) {
            let next = sortDescriptors[index].direction.next
            if next == .none {
                sortDescriptors.remove(at: index)
            } else {
                sortDescriptors[index].direction = next
                let updated = sortDescriptors.remove(at: index)
                sortDescriptors.append(updated)
            }
        } else {
            sortDescriptors.append(SortDescriptor(key: key, direction: .ascending))
        }
    }
}
