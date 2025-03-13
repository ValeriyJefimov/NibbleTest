//
//  SearchingIndicatorView.swift
//  NibbleTest

import SwiftUI

struct SearchingView: View {
    @State private var dotCount: Int = 0
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text("Searching")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(ColorPalette.label)
                Text(String(repeating: ".", count: dotCount))
                    .font(.title2)
                    .bold()
                    .foregroundStyle(ColorPalette.label)
                    .animation(.easeInOut(duration: 0.3), value: dotCount)
                    .onReceive(timer) { _ in
                        dotCount = (dotCount + 1) % 4
                    }
            }
            Spacer()
        }
    }
}

struct SearchingView_Previews: PreviewProvider {
    static var previews: some View {
        SearchingView()
    }
}
