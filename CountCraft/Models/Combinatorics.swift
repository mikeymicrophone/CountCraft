//
//  Combinatorics.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/17/26.
//

import Foundation

struct Combinatorics {
    static func choose(n: Int, k: Int) -> Int {
        guard n >= 0, k >= 0, k <= n else { return 0 }
        if k == 0 || k == n {
            return 1
        }
        let k = min(k, n - k)
        var result = 1
        for i in 1...k {
            let factor = n - k + i
            let divisor = greatestCommonDivisor(factor, i)
            result = (result / (i / divisor)) * (factor / divisor)
        }
        return result
    }

    static func greatestCommonDivisor(_ a: Int, _ b: Int) -> Int {
        var a = abs(a)
        var b = abs(b)
        while b != 0 {
            let temp = b
            b = a % b
            a = temp
        }
        return max(a, 1)
    }

    static func combinations(of elements: [Int], choose k: Int, limit: Int) -> [[Int]] {
        guard k >= 0 else { return [] }
        if k == 0 {
            return [[]]
        }
        guard k <= elements.count else { return [] }
        var results: [[Int]] = []
        var current: [Int] = []

        func backtrack(start: Int, remaining: Int) {
            guard results.count < limit else { return }
            if remaining == 0 {
                results.append(current)
                return
            }
            if start >= elements.count {
                return
            }
            for index in start..<elements.count {
                if results.count >= limit {
                    return
                }
                current.append(elements[index])
                backtrack(start: index + 1, remaining: remaining - 1)
                current.removeLast()
            }
        }

        backtrack(start: 0, remaining: k)
        return results
    }
}
