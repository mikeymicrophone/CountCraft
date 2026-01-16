//
//  RangeSlider.swift
//  CountCraft
//
//  Created by Mike Schwab on 1/16/26.
//

import SwiftUI

struct RangeSlider: View {
    let label: String
    @Binding var lowerValue: Int
    @Binding var upperValue: Int
    let bounds: ClosedRange<Int>
    let onReset: () -> Void
    var showsTickLabels: Bool = false

    private let handleSize: CGFloat = 24
    private let trackHeight: CGFloat = 6

    var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.headline)
                .frame(width: 28, alignment: .leading)

            GeometryReader { proxy in
                let width = proxy.size.width
                let trackWidth = max(width - handleSize, 1)
                let lowerX = xPosition(for: lowerValue, trackWidth: trackWidth)
                let upperX = xPosition(for: upperValue, trackWidth: trackWidth)

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.tertiarySystemBackground))
                        .frame(height: trackHeight)
                        .offset(y: (handleSize - trackHeight) / 2)

                    Capsule()
                        .fill(Color.accentColor)
                        .frame(width: max(upperX - lowerX, 0), height: trackHeight)
                        .offset(x: lowerX, y: (handleSize - trackHeight) / 2)

                    tickMarks(trackWidth: trackWidth)
                    if showsTickLabels {
                        tickLabels(trackWidth: trackWidth)
                    }

                    sliderHandle(value: lowerValue, trackWidth: trackWidth, isLower: true)
                    sliderHandle(value: upperValue, trackWidth: trackWidth, isLower: false)
                }
                .frame(height: showsTickLabels ? handleSize + 16 : handleSize)
            }
            .frame(height: showsTickLabels ? handleSize + 16 : handleSize)

            Button(action: onReset) {
                Image(systemName: resetIconName)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
    }

    private var resetIconName: String {
        if lowerValue == bounds.lowerBound && upperValue == bounds.upperBound {
            return "xmark"
        }
        return "arrow.left.and.right"
    }

    private func sliderHandle(value: Int, trackWidth: CGFloat, isLower: Bool) -> some View {
        let x = xPosition(for: value, trackWidth: trackWidth)
        return Circle()
            .fill(Color(.systemBackground))
            .frame(width: handleSize, height: handleSize)
            .overlay(
                Circle()
                    .stroke(Color.accentColor, lineWidth: 2)
            )
            .position(x: x + handleSize / 2, y: handleSize / 2)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let newValue = valueForLocation(gesture.location.x, trackWidth: trackWidth)
                        if isLower {
                            lowerValue = min(newValue, upperValue)
                        } else {
                            upperValue = max(newValue, lowerValue)
                        }
                    }
            )
    }

    private func tickMarks(trackWidth: CGFloat) -> some View {
        let values = Array(bounds.lowerBound...bounds.upperBound)
        return ForEach(values, id: \.self) { value in
            Rectangle()
                .fill(Color.secondary.opacity(0.35))
                .frame(width: 1, height: 6)
                .position(x: xPosition(for: value, trackWidth: trackWidth) + handleSize / 2, y: handleSize / 2)
        }
    }

    private func tickLabels(trackWidth: CGFloat) -> some View {
        let values = Array(bounds.lowerBound...bounds.upperBound)
        return ForEach(values, id: \.self) { value in
            Text("\(value)")
                .font(.caption2)
                .foregroundColor(.secondary)
                .position(x: xPosition(for: value, trackWidth: trackWidth) + handleSize / 2, y: handleSize + 10)
        }
    }

    private func xPosition(for value: Int, trackWidth: CGFloat) -> CGFloat {
        let range = max(bounds.upperBound - bounds.lowerBound, 1)
        let ratio = CGFloat(value - bounds.lowerBound) / CGFloat(range)
        return ratio * trackWidth
    }

    private func valueForLocation(_ location: CGFloat, trackWidth: CGFloat) -> Int {
        let clampedX = min(max(location - handleSize / 2, 0), trackWidth)
        let ratio = clampedX / trackWidth
        let rawValue = CGFloat(bounds.lowerBound) + ratio * CGFloat(bounds.upperBound - bounds.lowerBound)
        return Int(rawValue.rounded())
    }
}
