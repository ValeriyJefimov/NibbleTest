//
//  EmptyVSearchingiew.swift
//  NibbleTest

import SwiftUI

struct EmptySearchingView: View {
    enum ViewState {
        case title(String)
        case error(String)

        var title: String {
            switch self {
                case .title(let text): text
                case .error(let text): text
            }
        }

        var emoji: String {
        switch self {
                case .title: "🔍"
                case .error: "😔"
            }
        }
        var textColor: Color {
            switch self {
                case .title: .black
                case .error: .red
            }
        }
    }

    @State var state: ViewState

    var body: some View {
        VStack(spacing: 20) {
            VStack {
                Spacer()
                Text(state.emoji)
                    .font(.largeTitle)
                Text(state.title)
                    .foregroundStyle(ColorPalette.label)
                    .font(.title3.bold())
                    .foregroundColor(state.textColor)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    EmptySearchingView(state: .title("There is no book yet. Search some!"))
}
