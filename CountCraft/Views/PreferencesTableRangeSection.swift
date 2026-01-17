//
//  PreferencesTableRangeSection.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import SwiftUI

struct PreferencesTableRangeSection: View {
    @Binding var selectedOperation: OperationType
    let axisMinXBinding: Binding<Int>
    let axisMaxXBinding: Binding<Int>
    let axisMinYBinding: Binding<Int>
    let axisMaxYBinding: Binding<Int>
    let onResetX: () -> Void
    let onResetY: () -> Void

    var body: some View {
        Section("Table Range") {
            Picker("Table", selection: $selectedOperation) {
                ForEach(OperationType.allCases) { operation in
                    Text(operation.title).tag(operation)
                }
            }
            .pickerStyle(.segmented)

            RangeSlider(
                label: "X:",
                lowerValue: axisMinXBinding,
                upperValue: axisMaxXBinding,
                bounds: 0...12,
                onReset: {
                onResetX()
            },
                showsTickLabels: true
            )

            RangeSlider(
                label: "Y:",
                lowerValue: axisMinYBinding,
                upperValue: axisMaxYBinding,
                bounds: 0...12,
                onReset: {
                onResetY()
            },
                showsTickLabels: true
            )
        }
    }
}
