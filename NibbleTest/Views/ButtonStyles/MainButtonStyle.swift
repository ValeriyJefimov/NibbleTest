//
//  MainButtonStyle.swift
//  NibbleTest

import SwiftUI

struct MainButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.bold())
            .foregroundColor(ColorPalette.label)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(ColorPalette.secondaryLabel.opacity(0.3))
            .cornerRadius(12)
            .pressableEffect(configuration.isPressed)
    }
}

#Preview {
    Button {
        print("Speed button tapped")
    } label: {
        Text("Speed x1")
    }
    .buttonStyle(MainButtonStyle())
}
