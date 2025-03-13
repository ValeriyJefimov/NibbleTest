//
//  PlaybackButtonStyle.swift
//  NibbleTest

import SwiftUI

struct PlaybackButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(isEnabled ? ColorPalette.label : ColorPalette.secondaryLabel.opacity(0.5))
            .font(.title3.bold())
            .pressableEffect(configuration.isPressed)
    }
}

#Preview {
    VStack {
        Button {
            print("press")
        } label: {
            Image(systemName: "5.arrow.trianglehead.counterclockwise")
        }

        Button {
            print("press")
        } label: {
            Image(systemName: "5.arrow.trianglehead.counterclockwise")
        }
        .disabled(true)
    }
    .buttonStyle(PlaybackButtonStyle())

}
