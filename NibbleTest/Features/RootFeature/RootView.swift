//
//  RootView.swift
//  NibbleTest

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    @Bindable var store: StoreOf<RootFeature>

    init(store: StoreOf<RootFeature>) {
        UITabBar.appearance().isHidden = true
        self.store = store
    }
    
    var body: some View {
        VStack {
            TabView(selection: $store.tabBar.selectedTab.sending(\.tabBar.didChangeTab)) {

                PlayerView(store: store.scope(state: \.player, action: \.playerTab))
                    .tag(TabSwitchFeature.Tab.player)
                    .toolbar(.hidden, for: .tabBar)
                    .background(ColorPalette.background)

                BookSummaryView(store: store.scope(state: \.summary, action: \.summary))
                    .tag(TabSwitchFeature.Tab.chapters)
                    .toolbar(.hidden, for: .tabBar)
                    .background(ColorPalette.background)

            }

            Spacer(minLength: 20)

            TabSwitch(store: store.scope(state: \.tabBar, action: \.tabBar))
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
        }
        .background(ColorPalette.background)
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    RootView(
        store: Store(initialState: .init()) {
            RootFeature()
    }
  )
}
