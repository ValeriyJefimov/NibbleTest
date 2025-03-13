//
//  PlayPauseButton.swift
//  NibbleTest

import SwiftUI

struct PlayPauseButton: View {
    var state: PlayerFeature.PlayingState
    var action: () -> Void

    private var isPlaying: Bool {
        state == .play
    }

    private var isError: Bool {
        state == .error
    }


    var body: some View {
        Button(action: {
            withAnimation(.bouncy) {
                action()
            }
        }) {
            switch state {
                case .play, .pause:
                    ZStack {
                        Image(systemName: "play.fill")
                            .font(.largeTitle)
                            .opacity(isPlaying ? 0 : 1)
                            .scaleEffect(isPlaying ? 0.5 : 1)
                            .animation(.bouncy, value: isPlaying)
                            .foregroundStyle(ColorPalette.label)

                        Image(systemName: "pause.fill")
                            .font(.largeTitle)
                            .opacity(isPlaying ? 1 : 0)
                            .scaleEffect(isPlaying ? 1 : 0.5)
                            .animation(.bouncy, value: isPlaying)
                            .foregroundStyle(ColorPalette.label)
                    }
                    .transition(.opacity)
                case .loading:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .foregroundStyle(ColorPalette.label)
                        .font(.largeTitle.bold())
                case .error:
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle.bold())
                        .scaleEffect(isError ? 0.5 : 1)
                        .animation(.bouncy, value: isError)
                        .foregroundStyle(ColorPalette.systemRed)
            }
        }
    }
}

#Preview {
    VStack {
        PlayPauseButton(state: .error, action: {})
        PlayPauseButton(state: .loading, action: {})
        PlayPauseButton(state: .play, action: {})
        PlayPauseButton(state: .pause, action: {})
    }
}
