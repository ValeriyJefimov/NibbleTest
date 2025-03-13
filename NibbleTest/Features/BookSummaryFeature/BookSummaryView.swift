//
//  BookSummaryView.swift
//  NibbleTest

import ComposableArchitecture
import SwiftUI

struct BookSummaryView: View {
    @Bindable var store: StoreOf<BookSummaryFeature>

    var body: some View {
        VStack {
            HStack {
                Text("Book Details")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(ColorPalette.label)
                    .padding(.top, 8)
                Spacer()
            }
            .padding()

            TextField(
                "Search Chapters",
                text: $store.searchText.sending(\.updateSearchText),
                prompt: Text("Search book").foregroundColor(ColorPalette.secondaryLabel)
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .onSubmit {
                store.send(.fetchBookSummary(store.searchText))
            }
            .submitLabel(.search)

            switch store.searchState {
                case let .error(error):
                    EmptySearchingView(state: .error(error))
                case .nothing:
                    EmptySearchingView(state: .title("There is no book yet. Search some!"))
                case let .found(book):
                    mainView(book: book)
                case .search:
                    SearchingView()
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

private extension BookSummaryView {
    func mainView(book: Book) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 10) {
                ForEach(book.chapters, id: \ .title) { chapter in
                    Button {
                        store.send(.selectChapter(chapter))
                    } label: {
                        Text(chapter.title)
                    }
                    .buttonStyle(SummaryButtonStyle())
                }
            }
        }
        .padding(.horizontal)
        
    }
}

#Preview {
    BookSummaryView(
        store: Store(initialState: .empty) {
            BookSummaryFeature()
        }
    )
}

