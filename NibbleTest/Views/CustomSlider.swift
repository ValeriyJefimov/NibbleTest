//
//  CustomSlider.swift
//  NibbleTest

import SwiftUI

struct CustomSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double>

    var trackColor: Color = ColorPalette.secondaryLabel.opacity(0.3)
    var progressColor: Color = ColorPalette.systemBlue
    var thumbColor: Color = ColorPalette.systemBlue
    var thumbSize: CGFloat = 20

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(trackColor)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(progressColor)
                        .frame(width: progressWidth(in: geometry), height: 6)
                        .animation(.easeInOut(duration: 0.2), value: value)

                    Circle()
                        .fill(thumbColor)
                        .frame(width: thumbSize, height: thumbSize)
                        .offset(x: thumbOffset(in: geometry))
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: value)
                        .gesture(DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                withAnimation {
                                    let newValue = valueFromGesture(gesture, in: geometry)
                                    value = min(max(newValue, range.lowerBound), range.upperBound)
                                }
                            }
                        )
                }
            }

            Spacer()
        }
    }
}

private extension CustomSlider {
     func progressWidth(in geometry: GeometryProxy) -> CGFloat {
        let totalWidth = geometry.size.width
        let progress = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return totalWidth * CGFloat(progress)
    }

    func thumbOffset(in geometry: GeometryProxy) -> CGFloat {
        let totalWidth = geometry.size.width
        let progress = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return totalWidth * CGFloat(progress) - (thumbSize / 2)
    }

    func valueFromGesture(_ gesture: DragGesture.Value, in geometry: GeometryProxy) -> Double {
        let totalWidth = geometry.size.width
        let percentage = min(max(gesture.location.x / totalWidth, 0), 1)
        return range.lowerBound + (range.upperBound - range.lowerBound) * Double(percentage)
    }
}

#Preview {
    HStack {
        Text("20:20")
            .font(.caption)
            .foregroundColor(.gray)
            .frame(maxWidth: 40)
        CustomSlider(
            value: .constant(20),
            range: 0...40,
            thumbColor: .blue,
            thumbSize: 20
        )
        Text("20:20")
            .font(.caption)
            .foregroundColor(.gray)
            .frame(maxWidth: 40)
    }
    .frame(maxHeight: 35)
}
