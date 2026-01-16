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

    var body: some View {
        TabView {
            TablePracticeView(operation: .addition, guesses: guesses, onGuess: recordGuess)
                .tabItem {
                    Label("Addition", systemImage: "plus")
                }

            TablePracticeView(operation: .multiplication, guesses: guesses, onGuess: recordGuess)
                .tabItem {
                    Label("Multiply", systemImage: "multiply")
                }
        }
    }

    private func recordGuess(_ guess: PracticeGuess) {
        withAnimation {
            modelContext.insert(guess)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: PracticeGuess.self, inMemory: true)
}
