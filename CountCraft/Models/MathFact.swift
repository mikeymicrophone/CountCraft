//
//  MathFact.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import Foundation

struct MathFact: Identifiable, Hashable {
    let a: Int
    let b: Int

    var id: String { "\(a)-\(b)" }
}

struct FactKey: Hashable {
    let a: Int
    let b: Int
}
