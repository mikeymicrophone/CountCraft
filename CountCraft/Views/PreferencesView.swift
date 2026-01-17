//
//  PreferencesView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import SwiftUI
import SwiftData

struct PreferencesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Profile.name, order: .forward) private var profiles: [Profile]

    @AppStorage("prefColorCodedNumbers") private var colorCodedNumbers = false
    @AppStorage("prefNumberFont") private var numberFontRaw = NumberFontChoice.rounded.rawValue
    @AppStorage("prefChoiceDifficulty") private var difficultyRaw = ChoiceDifficulty.medium.rawValue
    @AppStorage("prefHintsShown") private var hintsShown = true
    @State private var selectedOperation: OperationType = .addition
    @State private var axisRefresh = 0
    @AppStorage("selectedProfileId") private var selectedProfileId = ""
    @State private var newProfileName = ""

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                PreferencesProfilesSection(
                    profiles: profiles,
                    selectedProfileId: selectedProfileId,
                    newProfileName: $newProfileName,
                    onSelectProfile: { profile in
                        selectedProfileId = profile.id.uuidString
                    },
                    onAddProfile: addProfile,
                    nameBinding: profileNameBinding
                )

                PreferencesNumbersSection(
                    colorCodedNumbers: $colorCodedNumbers,
                    hintsShown: $hintsShown,
                    numberFontRaw: $numberFontRaw
                )

                PreferencesMultipleChoiceSection(
                    difficultyRaw: $difficultyRaw,
                    description: difficultyDescription
                )

                PreferencesTableRangeSection(
                    selectedOperation: $selectedOperation,
                    axisMinXBinding: axisMinXBinding,
                    axisMaxXBinding: axisMaxXBinding,
                    axisMinYBinding: axisMinYBinding,
                    axisMaxYBinding: axisMaxYBinding,
                    onResetX: {
                        setAxisMinX(0)
                        setAxisMaxX(12)
                    },
                    onResetY: {
                        setAxisMinY(0)
                        setAxisMaxY(12)
                    }
                )
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

    private func addProfile() {
        let trimmed = newProfileName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let profile = Profile(name: trimmed)
        modelContext.insert(profile)
        selectedProfileId = profile.id.uuidString
        newProfileName = ""
    }

    private func profileNameBinding(for profile: Profile) -> Binding<String> {
        Binding(
            get: { profile.name },
            set: { newValue in
                let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                profile.name = trimmed.isEmpty ? profile.name : trimmed
            }
        )
    }
}
