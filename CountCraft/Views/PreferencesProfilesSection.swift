//
//  PreferencesProfilesSection.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import SwiftUI

struct PreferencesProfilesSection: View {
    let profiles: [Profile]
    let selectedProfileId: String
    @Binding var newProfileName: String
    let onSelectProfile: (Profile) -> Void
    let onAddProfile: () -> Void
    let nameBinding: (Profile) -> Binding<String>

    var body: some View {
        Section("Profiles") {
            ForEach(profiles) { profile in
                HStack(spacing: 12) {
                    TextField("Profile name", text: nameBinding(profile))
                    Spacer()
                    Button {
                        onSelectProfile(profile)
                    } label: {
                        Image(systemName: profile.id.uuidString == selectedProfileId ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(profile.id.uuidString == selectedProfileId ? .accentColor : .secondary)
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(spacing: 8) {
                TextField("New profile name", text: $newProfileName)
                Button("Add") {
                    onAddProfile()
                }
                .disabled(newProfileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}
