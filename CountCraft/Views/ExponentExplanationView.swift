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
    let numberFont: (CGFloat, Font.Weight) -> Font

    @State private var currentStep: Int?
    @State private var isPlaying: Bool = false
    @State private var timer: Timer?

    private var step: Int {
        currentStep ?? exponent
    }

    private var maxStep: Int {
        min(max(exponent, 1), 12)
    }

    private func valueAtStep(_ step: Int) -> Int {
        Int(pow(Double(base), Double(step)))
    }

    private func labelForStep(_ step: Int) -> String {
        if step == 1 {
            return "\(base)"
        } else {
            let previousValue = valueAtStep(step - 1)
            let currentValue = valueAtStep(step)
            return "\(base) groups of \(previousValue) = \(currentValue)"
        }
    }

    private func startPlaying() {
        isPlaying = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            if step < maxStep {
                currentStep = step + 1
            } else {
                currentStep = 1
            }
        }
    }

    private func stopPlaying() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(labelForStep(step))
                .font(numberFont(18, .semibold))
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
                .frame(maxWidth: .infinity, minHeight: 476)
                .animation(.easeInOut(duration: 0.2), value: step)
                .padding(.bottom, 30)
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
