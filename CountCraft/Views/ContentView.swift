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
    @State private var selectedTab: TabSelection = .addition
    @State private var pendingExplanation: [OperationType: MathFact] = [:]

    var body: some View {
        let currentGuesses = activeGuesses
        let currentProfile = selectedProfile
        TabView(selection: $selectedTab) {
            LazyTabItem(selection: selectedTab, tag: .addition) {
                TablePracticeView(
                    operation: .addition,
                    guesses: currentGuesses,
                    profile: currentProfile,
                    onGuess: recordGuess,
                    onSwitchOperation: switchOperation,
                    pendingExplanation: pendingBinding(for: .addition)
                )
            }
            .tabItem {
                Label("Addition", systemImage: "plus")
            }
            .tag(TabSelection.addition)

            LazyTabItem(selection: selectedTab, tag: .multiplication) {
                TablePracticeView(
                    operation: .multiplication,
                    guesses: currentGuesses,
                    profile: currentProfile,
                    onGuess: recordGuess,
                    onSwitchOperation: switchOperation,
                    pendingExplanation: pendingBinding(for: .multiplication)
                )
            }
            .tabItem {
                Label("Multiply", systemImage: "multiply")
            }
            .tag(TabSelection.multiplication)

            LazyTabItem(selection: selectedTab, tag: .exponent) {
                TablePracticeView(
                    operation: .exponent,
                    guesses: currentGuesses,
                    profile: currentProfile,
                    onGuess: recordGuess,
                    onSwitchOperation: switchOperation,
                    pendingExplanation: pendingBinding(for: .exponent)
                )
            }
            .tabItem {
                Label("Exponents", systemImage: "function")
            }
            .tag(TabSelection.exponent)

            LazyTabItem(selection: selectedTab, tag: .sets) {
                TablePracticeView(
                    operation: .sets,
                    guesses: currentGuesses,
                    profile: currentProfile,
                    onGuess: recordGuess,
                    onSwitchOperation: switchOperation,
                    pendingExplanation: pendingBinding(for: .sets)
                )
            }
            .tabItem {
                Label("Sets", systemImage: "square.grid.2x2")
            }
            .tag(TabSelection.sets)

            LazyTabItem(selection: selectedTab, tag: .probability) {
                ProbabilityView(onSwitchOperation: switchOperation)
            }
            .tabItem {
                Label("Probability", systemImage: "chart.bar.xaxis")
            }
            .tag(TabSelection.probability)

            LazyTabItem(selection: selectedTab, tag: .review) {
                ReviewGuessesView(guesses: currentGuesses)
            }
            .tabItem {
                Label("Review", systemImage: "list.bullet.rectangle")
            }
            .tag(TabSelection.review)
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

    private func switchOperation(_ operation: OperationType, fact: MathFact) {
        pendingExplanation[operation] = fact
        switch operation {
        case .addition:
            selectedTab = .addition
        case .multiplication:
            selectedTab = .multiplication
        case .exponent:
            selectedTab = .exponent
        case .sets:
            selectedTab = .sets
        }
    }

    private func pendingBinding(for operation: OperationType) -> Binding<MathFact?> {
        Binding(
            get: { pendingExplanation[operation] },
            set: { newValue in
                if let newValue {
                    pendingExplanation[operation] = newValue
                } else {
                    pendingExplanation.removeValue(forKey: operation)
                }
            }
        )
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

private enum TabSelection: Hashable {
    case addition
    case multiplication
    case exponent
    case sets
    case review
    case probability
}

private struct LazyTabItem<Content: View>: View {
    let selection: TabSelection
    let tag: TabSelection
    let content: () -> Content

    @State private var hasLoaded = false

    init(
        selection: TabSelection,
        tag: TabSelection,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.selection = selection
        self.tag = tag
        self.content = content
    }

    var body: some View {
        Group {
            if hasLoaded || selection == tag {
                content()
                    .onAppear {
                        hasLoaded = true
                    }
            } else {
                Color.clear
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Profile.self, PracticeGuess.self], inMemory: true)
}
