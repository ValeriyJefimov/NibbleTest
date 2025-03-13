//
//  PressableEffect.swift
//  NibbleTest

import SwiftUI

struct PressableEffect: ViewModifier {
    private var isPressed: Bool = false

    init(isPressed: Bool = false) {
        self.isPressed = isPressed
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.bouncy, value: isPressed)
            .shadow(color: .black.opacity(isPressed ? 0.1 : 0.05), radius: isPressed ? 2 : 4, x: 0, y: isPressed ? 1 : 2)
    }
}

extension View {
    func pressableEffect(_ isPressed: Bool) -> some View {
        self.modifier(PressableEffect(isPressed: isPressed))
    }
}
