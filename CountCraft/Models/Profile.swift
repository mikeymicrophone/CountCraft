//
//  Profile.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import Foundation
import SwiftData

@Model
final class Profile {
    @Attribute(.unique) var id: UUID
    var name: String
    @Relationship(inverse: \PracticeGuess.profile) var guesses: [PracticeGuess]

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.guesses = []
    }
}
