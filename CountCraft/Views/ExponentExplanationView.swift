//
//  ExponentExplanationView.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import SwiftUI

struct ExponentExplanationView: View {
    let base: Int
    let exponent: Int
    let color: Color
    let numberStyle: NumberStyle

    @State private var currentStep: Int?
    @State private var isPlaying: Bool = false
    @State private var playTask: Task<Void, Never>?

    private var maxStep: Int {
        min(max(exponent, 1), 12)
    }

    private var step: Int {
        min(max(currentStep ?? exponent, 1), maxStep)
    }

    private func valueAtStep(_ step: Int) -> Int {
        Int(pow(Double(base), Double(step)))
    }

    private func labelForStep(_ step: Int) -> String {
        if step == 1 {
            return NumberFormatting.string(from: base)
        }
        let leftExp = step / 2
        let rightExp = step - leftExp
        let leftValue = valueAtStep(leftExp)
        let rightValue = valueAtStep(rightExp)
        let currentValue = valueAtStep(step)
        let groupLabel = leftValue == 1 ? "group" : "groups"
        return "\(NumberFormatting.string(from: leftValue)) \(groupLabel) of \(NumberFormatting.string(from: rightValue)) = \(NumberFormatting.string(from: currentValue))"
    }

    private func playbackDelay(for step: Int) -> TimeInterval {
        switch step {
        case 1...3:
            return 1.5
        case 4...6:
            return 2.4
        case 7...9:
            return 4.0
        default:
            return 5.8
        }
    }

    private func startPlaying() {
        stopPlaying()
        isPlaying = true
        playTask = Task { @MainActor in
            while !Task.isCancelled && isPlaying {
                let delay = playbackDelay(for: step)
                try? await Task.sleep(for: .seconds(delay))
                guard !Task.isCancelled && isPlaying else { break }
                if step < maxStep {
                    currentStep = step + 1
                } else {
                    currentStep = 1
                }
            }
        }
    }

    private func stopPlaying() {
        isPlaying = false
        playTask?.cancel()
        playTask = nil
    }

    var body: some View {
        VStack(spacing: 12) {
            Text(labelForStep(step))
                .font(numberStyle.font(size: 18, weight: .semibold))
                .animation(.none, value: step)

            HStack(spacing: 12) {
                Button {
                    if isPlaying {
                        stopPlaying()
                    } else {
                        startPlaying()
                    }
                } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.accentColor)
                        .frame(width: 32, height: 32)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Picker("Step", selection: Binding(
                    get: { step },
                    set: { currentStep = $0 }
                )) {
                    ForEach(1...maxStep, id: \.self) { s in
                        Text("\(base)\(superscript(s))").tag(s)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)

            ExponentSceneView(base: base, depth: step, color: color)
                .frame(maxWidth: .infinity, minHeight: 300, idealHeight: 340, maxHeight: 380)
                .animation(.easeInOut(duration: 0.2), value: step)
                .padding(.bottom, 16)
        }
        .onDisappear {
            stopPlaying()
        }
    }

    private func superscript(_ n: Int) -> String {
        let superscripts = ["⁰", "¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹"]
        if n < 10 {
            return superscripts[n]
        }
        return String(n).map { superscripts[Int(String($0))!] }.joined()
    }
}
