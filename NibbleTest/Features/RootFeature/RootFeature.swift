//
//  RootFeature.swift
//  NibbleTest

import ComposableArchitecture

@Reducer
struct RootFeature: Reducer {
    
    @ObservableState
    public struct State: Equatable {
        var player: PlayerFeature.State = .empty
        var summary: BookSummaryFeature.State = .empty
        var tabBar: TabSwitchFeature.State = .init(selectedTab: .chapters)
    }
    
    public enum Action {
        case playerTab(PlayerFeature.Action)
        case summary(BookSummaryFeature.Action)
        case tabBar(TabSwitchFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.tabBar, action: \.tabBar) {
            TabSwitchFeature()
        }

        Scope(state: \.summary, action: \.summary) {
            BookSummaryFeature()
        }._printChanges()

        Scope(state: \.player, action: \.playerTab) {
            PlayerFeature()
        }
        Reduce<State, Action> { state, action in
            switch action {
                case .tabBar(.didChangeTab):
                    return .none
                case .playerTab:
                    return .none
                case let .summary(.selectChapter(chapter)):
                    if let index = state.summary.book?.chapters.firstIndex(where: { $0.title == chapter.title }) {
                        state.player.currentChapterIndex = index
                        state.tabBar.selectedTab = .player
                    }

                    return .send(.playerTab(.loadPlayable))
                case let .summary(.bookSummaryResponse(.success(book))):
                    state.player.book = book
                    return .none
                case .summary:
                    return .none
            }
        }
    }
}
