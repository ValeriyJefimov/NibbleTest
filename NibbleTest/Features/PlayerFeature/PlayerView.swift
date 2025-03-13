//
//  PlayerView.swift
//  NibbleTest

import ComposableArchitecture
import Kingfisher
import SwiftUI

struct PlayerView: View {
    @Bindable var store: StoreOf<PlayerFeature>

    var body: some View {
        if store.currentChapter != nil {
            mainView
        } else {
            emptyView
        }
    }

}

private extension PlayerView {
    var mainView: some View {
        VStack(spacing: 20) {
            if let cover = store.book?.cover {
                coverImage(cover: cover)
            }
            if let chaptersCount = store.chaptersCount {
                chaptersInfo(count: chaptersCount)
            }
            if let currentChapter = store.currentChapter {
                currentChapterTitle(chapter: currentChapter)
            }
            Spacer()
            playbackControls
            speedAdjustmentButton
            chapterNavigationButtons
        }
    }

    var emptyView: some View {
        EmptySearchingView(state: .title("There is no book yet. Search some!"))
            .background(ColorPalette.background)
    }

    func coverImage(cover: URL) -> some View {
        KFImage(cover)
            .resizable()
            .placeholder { ProgressView().progressViewStyle(CircularProgressViewStyle(tint: ColorPalette.systemBlue)) }
            .scaledToFit()
            .cornerRadius(12)
    }

    func chaptersInfo(count: String) -> some View {
        Text(count)
            .font(.caption)
            .foregroundColor(ColorPalette.secondaryLabel)
            .tracking(1)

    }

    func currentChapterTitle(chapter: Chapter) -> some View {
        Text(chapter.title)
            .foregroundStyle(ColorPalette.label)
            .font(.title3)
            .fontWeight(.semibold)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
    }

    var playbackControls: some View {
        HStack(spacing: 10) {
            Text(store.currentDurationFormatted)
                .font(.caption)
                .foregroundStyle(ColorPalette.secondaryLabel)
                .frame(maxWidth: 40)

            CustomSlider(
                value: $store.currentDuration.sending(\.currentDurationChanged),
                range: 0...store.totalDuration,
                thumbColor: ColorPalette.systemBlue,
                thumbSize: 20
            )
            .padding(.horizontal, 5)

            Text(store.totalDurationFormatted)
                .font(.caption)
                .foregroundStyle(ColorPalette.secondaryLabel)
                .frame(maxWidth: 40)
        }
        .frame(maxHeight: 35)
        .padding(.horizontal, 10)
    }

    var speedAdjustmentButton: some View {
        Button {
            store.send(.adjustSpeedButtonPressed)
        } label: {
            Text(store.playbackSpeedTitle)
        }
        .buttonStyle(MainButtonStyle())
    }

    var chapterNavigationButtons: some View {
        HStack(spacing: 30) {
            Button {
                store.send(.prevChapterButtonPressed)
            } label: {
                Image(systemName: "backward.end.fill")
            }
            .disabled(!store.canPlayPrevChapter)

            Button {
                store.send(.paybackBackButtonPressed)
            } label: {
                Image(systemName: "gobackward.5")
            }

            PlayPauseButton(state: store.playingState) {
                store.send(.playPauseButtonPressed)
            }

            Button {
                store.send(.paybackForwardButtonPressed)
            } label: {
                Image(systemName: "10.arrow.trianglehead.clockwise")
            }

            Button {
                store.send(.nextChapterButtonPressed)
            } label: {
                Image(systemName: "forward.end.fill")
            }
            .disabled(!store.canPlayNextChapter)
        }
        .frame(height: 35)
        .buttonStyle(PlaybackButtonStyle())
        .padding(.top, 10)
    }
}

#Preview {
    PlayerView(
        store: Store(initialState: .empty) {
            PlayerFeature()
        }
    )
}
