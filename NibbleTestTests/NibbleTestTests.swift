//
//  NibbleTestTests.swift
//  NibbleTest

import ComposableArchitecture
import XCTest
@testable import NibbleTest

final class NibbleTestTests: XCTestCase {
    enum SomeError: Error {
        case unknown
    }

    func testSerachForSummaryHappyPath() async {
        let store = await TestStore(
            initialState: BookSummaryFeature.State(searchText: "")
        ) {
            BookSummaryFeature()
        } withDependencies: {
            $0.summaryClient = .init(bookSummary: { _ in
                    .mock()
            })
        }

        await store.send(.fetchBookSummary("Test")) {
            $0.searchState = .search
        }

        await store.receive(\.bookSummaryResponse) {
            $0.searchState = .found(Book.mock())
        }
    }

    func testSerachForSummaryFailedPath() async {
        let store = await TestStore(
            initialState: BookSummaryFeature.State(searchText: "")
        ) {
            BookSummaryFeature()
        } withDependencies: {
            $0.summaryClient = .init(bookSummary: { _ in
                throw SomeError.unknown
            })
        }

        await store.send(.fetchBookSummary("Test")) {
            $0.searchState = .search
        }

        await store.receive(\.bookSummaryResponse) {
            $0.searchState = .error("Something went wrong, try search again!")
        }
    }

    func testUpdateSearchTest() async {
        let store = await TestStore(
            initialState: BookSummaryFeature.State(searchText: "")
        ) {
            BookSummaryFeature()
        }

        await store.send(.updateSearchText("Test")) {
            $0.searchText = "Test"
        }
    }

    func currentDurationChangedTest() async {
        let store = await TestStore(
            initialState: PlayerFeature.State.mock()
        ) {
            PlayerFeature()
        } withDependencies: {
            $0.textToSpeechClient = .init(textToSpeech: { text in
                return URL(string: "testurl.mp3")!
            })
        }

        await store.send(.currentDurationChanged(10)) {
            $0.currentDuration = 10
        }
    }

    func paybackForwardButtonPressedTest() async {
        let store = await TestStore(
            initialState: PlayerFeature.State.mock(totalDuration: 20, currentDuration: 10)
        ) {
            PlayerFeature()
        }

        await store.send(.paybackForwardButtonPressed)

        await store.receive(\.nextChapterButtonPressed) {
            $0.currentChapterIndex = 1
        }
    }

    func payableDownloadedTest() async {
        let store = await TestStore(
            initialState: PlayerFeature.State.mock(totalDuration: 20, currentDuration: 10)
        ) {
            PlayerFeature()
        } withDependencies: {
            $0.audioPlayer = .init(
                loadAudio: { _ in 10},
                play: {},
                pause: {},
                stop: {},
                playbackBack: { _ in },
                playbackForward: { _ in },
                setSpeed: { _ in },
                currentTime: { 0 },
                duration: { 0 },
                onPlaybackEnded: {.finished },
                stopTrackingAudioEnd: {}
            )
        }

        let url = URL(string: "testurl.mp3")!

        await store.send(.payableDownloaded(url)) {
            $0.currentPlayable = url
            $0.playingState = .pause
        }

        await store.receive(\.setupPlayableTimeline) {
            $0.totalDuration = 10
        }
    }

}

extension PlayerFeature.State {
    static func mock(
        book: Book? = .mock(),
        currentChapterIndex: Int = 0,
        currentSpeedValue: PlayerFeature.SpeedValue = .regular,
        totalDuration: TimeInterval = 0,
        currentDuration: TimeInterval = 0,
        playingState: PlayerFeature.PlayingState = .play,
        currentPlayable: URL? = nil
    ) -> Self {
        .init(
            book: book,
            currentSpeedValue: currentSpeedValue,
            totalDuration: totalDuration,
            currentDuration: currentDuration,
            playingState: playingState,
            currentPlayable: currentPlayable
        )
    }
}
