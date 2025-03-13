//
//  TabSwitchFeature.swift
//  NibbleTest

import ComposableArchitecture

@Reducer
public struct TabSwitchFeature {
    public enum Tab: Equatable {
        case player
        case chapters
    }

    @ObservableState
    public struct State: Equatable, Hashable {
        var selectedTab: Tab = .player
    }

    public enum Action {
        case didChangeTab(Tab)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
                case let .didChangeTab(tab):
                    state.selectedTab = tab
                    return .none
            }
        }
    }
}
