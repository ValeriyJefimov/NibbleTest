//
//  BookSummaryFeature.swift
//  NibbleTest

import ComposableArchitecture

@Reducer
struct BookSummaryFeature {
    @Dependency(\.summaryClient) var summaryClient

    enum CancelID {
        case summarize
    }

    @ObservableState
    struct State: Equatable {
        enum SearchState: Equatable {
            case nothing
            case search
            case error(String)
            case found(Book)
        }

        var searchText: String = ""
        var searchState: SearchState

        public init(searchText: String, searchState: SearchState = .nothing) {
            self.searchText = searchText
            self.searchState = searchState
        }

        public var book: Book? {
            guard case let .found(book) = searchState else {
                return nil
            }
            
            return book
        }
    }

    enum Action {
        case fetchBookSummary(String)
        case bookSummaryResponse(Result<Book, Error>)
        case updateSearchText(String)
        case selectChapter(Chapter)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .fetchBookSummary(let bookName):
                    state.searchState = .search
                    return .run { send in
                        do {
                            let book = try await summaryClient.bookSummary(bookName)
                            await send(.bookSummaryResponse(.success(book)))
                        } catch {
                            await send(.bookSummaryResponse(.failure(error)))
                        }
                    }
                    .cancellable(id: CancelID.summarize)

                case .bookSummaryResponse(let result):
                    switch result {
                        case .success(let book):
                            state.searchState = .found(book)
                        case .failure:
                            state.searchState = .error("Something went wrong, try search again!")
                    }
                    return .none

                case .updateSearchText(let text):
                    state.searchText = text
                    return .cancel(id: CancelID.summarize)

                case .selectChapter:
                    return .none
            }
        }
    }

    public static var test: Self = .init(summaryClient: .init(\.summaryClient))
}

extension BookSummaryFeature.State {
    public static var empty: Self = .init(searchText: "")
}
