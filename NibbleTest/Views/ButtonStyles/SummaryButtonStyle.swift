//
//  SummaryButtonStyle.swift
//  NibbleTest

import SwiftUI

struct SummaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 10)
            .padding(.horizontal)
            .background(ColorPalette.secondaryLabel.opacity(0.1))
            .foregroundStyle(ColorPalette.label)
            .cornerRadius(8)
            .pressableEffect(configuration.isPressed)
    }
}

#Preview {
    Button {
        print("press")
    } label: {
        Text("press me")
    }
    .buttonStyle(SummaryButtonStyle())
}
