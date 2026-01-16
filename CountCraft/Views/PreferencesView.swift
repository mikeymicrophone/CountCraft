//
//  PreferencesView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import SwiftUI

struct PreferencesView: View {
    @AppStorage("prefColorCodedNumbers") private var colorCodedNumbers = false
    @AppStorage("prefNumberFont") private var numberFontRaw = NumberFontChoice.rounded.rawValue
    @AppStorage("prefChoiceDifficulty") private var difficultyRaw = ChoiceDifficulty.medium.rawValue
    @State private var selectedOperation: OperationType = .addition
    @State private var axisRefresh = 0

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Numbers") {
                    Toggle("Color-code 0–12", isOn: $colorCodedNumbers)

                    Picker("Number Font", selection: $numberFontRaw) {
                        ForEach(NumberFontChoice.allCases) { choice in
                            Text(choice.title).tag(choice.rawValue)
                        }
                    }
                }

                Section("Multiple Choice") {
                    Picker("Challenge Level", selection: $difficultyRaw) {
                        ForEach(ChoiceDifficulty.allCases) { difficulty in
                            Text(difficulty.title).tag(difficulty.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text(difficultyDescription)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                Section("Table Range") {
                    Picker("Table", selection: $selectedOperation) {
                        ForEach(OperationType.allCases) { operation in
                            Text(operation.title).tag(operation)
                        }
                    }
                    .pickerStyle(.segmented)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("X Axis (top)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Stepper("Min: \(axisMinX)", value: axisMinXBinding, in: 0...12)
                        Stepper("Max: \(axisMaxX)", value: axisMaxXBinding, in: 0...12)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Y Axis (side)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Stepper("Min: \(axisMinY)", value: axisMinYBinding, in: 0...12)
                        Stepper("Max: \(axisMaxY)", value: axisMaxYBinding, in: 0...12)
                    }

                    Button("Reset Grid Limits") {
                        setAxisMinX(0)
                        setAxisMaxX(12)
                        setAxisMinY(0)
                        setAxisMaxY(12)
                    }
                }
            }
            .navigationTitle("Preferences")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var difficultyDescription: String {
        let choice = ChoiceDifficulty(rawValue: difficultyRaw) ?? .medium
        switch choice {
        case .easy:
            return "Distractors stay further from the correct answer."
        case .medium:
            return "Distractors mix near and mid-range values."
        case .hard:
            return "Distractors cluster close to the correct answer."
        }
    }

    private var axisMinX: Int {
        UserDefaults.standard.integer(forKey: gridKey("prefAxisMinX"))
    }

    private var axisMaxX: Int {
        UserDefaults.standard.object(forKey: gridKey("prefAxisMaxX")) as? Int ?? 12
    }

    private var axisMinY: Int {
        UserDefaults.standard.integer(forKey: gridKey("prefAxisMinY"))
    }

    private var axisMaxY: Int {
        UserDefaults.standard.object(forKey: gridKey("prefAxisMaxY")) as? Int ?? 12
    }

    private var axisMinXBinding: Binding<Int> {
        Binding(
            get: {
                _ = axisRefresh
                return axisMinX
            },
            set: { setAxisMinX($0) }
        )
    }

    private var axisMaxXBinding: Binding<Int> {
        Binding(
            get: {
                _ = axisRefresh
                return axisMaxX
            },
            set: { setAxisMaxX($0) }
        )
    }

    private var axisMinYBinding: Binding<Int> {
        Binding(
            get: {
                _ = axisRefresh
                return axisMinY
            },
            set: { setAxisMinY($0) }
        )
    }

    private var axisMaxYBinding: Binding<Int> {
        Binding(
            get: {
                _ = axisRefresh
                return axisMaxY
            },
            set: { setAxisMaxY($0) }
        )
    }

    private func setAxisMinX(_ value: Int) {
        let clamped = clamp(value)
        UserDefaults.standard.set(clamped, forKey: gridKey("prefAxisMinX"))
        if clamped > axisMaxX {
            UserDefaults.standard.set(clamped, forKey: gridKey("prefAxisMaxX"))
        }
        axisRefresh += 1
    }

    private func setAxisMaxX(_ value: Int) {
        let clamped = clamp(value)
        UserDefaults.standard.set(clamped, forKey: gridKey("prefAxisMaxX"))
        if clamped < axisMinX {
            UserDefaults.standard.set(clamped, forKey: gridKey("prefAxisMinX"))
        }
        axisRefresh += 1
    }

    private func setAxisMinY(_ value: Int) {
        let clamped = clamp(value)
        UserDefaults.standard.set(clamped, forKey: gridKey("prefAxisMinY"))
        if clamped > axisMaxY {
            UserDefaults.standard.set(clamped, forKey: gridKey("prefAxisMaxY"))
        }
        axisRefresh += 1
    }

    private func setAxisMaxY(_ value: Int) {
        let clamped = clamp(value)
        UserDefaults.standard.set(clamped, forKey: gridKey("prefAxisMaxY"))
        if clamped < axisMinY {
            UserDefaults.standard.set(clamped, forKey: gridKey("prefAxisMinY"))
        }
        axisRefresh += 1
    }

    private func clamp(_ value: Int) -> Int {
        min(max(value, 0), 12)
    }

    private func gridKey(_ baseKey: String) -> String {
        "\(baseKey)-\(selectedOperation.rawValue)"
    }
}
