//
//  ContentView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PracticeGuess.timestamp, order: .forward) private var guesses: [PracticeGuess]
    @Query(sort: \Profile.name, order: .forward) private var profiles: [Profile]
    @AppStorage("selectedProfileId") private var selectedProfileId = ""

    var body: some View {
        TabView {
            TablePracticeView(
                operation: .addition,
                guesses: activeGuesses,
                profile: selectedProfile,
                onGuess: recordGuess
            )
                .tabItem {
                    Label("Addition", systemImage: "plus")
                }

            TablePracticeView(
                operation: .multiplication,
                guesses: activeGuesses,
                profile: selectedProfile,
                onGuess: recordGuess
            )
                .tabItem {
                    Label("Multiply", systemImage: "multiply")
                }

            TablePracticeView(
                operation: .exponent,
                guesses: activeGuesses,
                profile: selectedProfile,
                onGuess: recordGuess
            )
                .tabItem {
                    Label("Exponents", systemImage: "function")
                }

            ReviewGuessesView(guesses: activeGuesses)
                .tabItem {
                    Label("Review", systemImage: "list.bullet.rectangle")
                }
        }
        .onAppear(perform: ensureProfileSelection)
        .onChange(of: profiles) { _, _ in
            ensureProfileSelection()
        }
    }

    private func recordGuess(_ guess: PracticeGuess) {
        withAnimation {
            modelContext.insert(guess)
        }
    }

    private var selectedProfile: Profile? {
        guard let id = UUID(uuidString: selectedProfileId) else { return profiles.first }
        return profiles.first { $0.id == id }
    }

    private var activeGuesses: [PracticeGuess] {
        guard let profileId = selectedProfile?.id else { return [] }
        return guesses.filter { $0.profile?.id == profileId }
    }

    private func ensureProfileSelection() {
        if profiles.isEmpty {
            let profile = Profile(name: "Default")
            modelContext.insert(profile)
            selectedProfileId = profile.id.uuidString
            for guess in guesses where guess.profile == nil {
                guess.profile = profile
            }
            return
        }

        if let selected = selectedProfile {
            selectedProfileId = selected.id.uuidString
        } else if let first = profiles.first {
            selectedProfileId = first.id.uuidString
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Profile.self, PracticeGuess.self], inMemory: true)
}
