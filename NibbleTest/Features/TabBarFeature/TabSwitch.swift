//
//  TabSwitch.swift
//  NibbleTest

import SwiftUI
import ComposableArchitecture

struct TabSwitch: View {
    let store: StoreOf<TabSwitchFeature>

    var body: some View {
        HStack {
            ZStack {
                HStack {
                    if store.selectedTab != .player { Spacer() }
                    Circle()
                        .fill(ColorPalette.systemBlue)
                        .frame(width: 65, height: 55)
                        .transition(.move(edge: store.selectedTab == .player ? .leading : .trailing))
                    if  store.selectedTab == .player { Spacer() }
                }

                HStack {
                    Image(systemName: "headphones")
                        .foregroundColor(store.selectedTab == .player ? .white : ColorPalette.label)
                        .font(.title2.bold())

                    Spacer()

                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(store.selectedTab == .player ? ColorPalette.label : .white)
                        .font(.title2.bold())
                }
                .padding(.horizontal, 20)
            }
            .frame(width: 130, height: 65)
            .background(ColorPalette.systemBackground)
            .cornerRadius(40)
            .overlay(
                RoundedRectangle(cornerRadius: 400)
                    .stroke(ColorPalette.secondaryLabel.opacity(0.5), lineWidth: 1)
            )
            .onTapGesture {
                // Absence of 'return' will cause compiler error
                // More https://forums.swift.org/t/adding-withanimation-to-button-action-result-in-compile-error/67473/4
                return withAnimation(.bouncy) {
                    store.send(.didChangeTab(store.selectedTab == .player ? .chapters : .player))
                }
            }
        }
    }
}

#Preview {
    TabSwitch(
        store: Store(initialState: .init(selectedTab: .chapters)) {
            TabSwitchFeature()
        }
    )
}
