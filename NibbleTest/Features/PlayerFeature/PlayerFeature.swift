//
//  PlayerFeature.swift
//  NibbleTest

import SwiftUI
import ComposableArchitecture

@Reducer
struct PlayerFeature {
    @Dependency(\.textToSpeechClient) var textToSpeechClient
    @Dependency(\.audioPlayer) var audioPlayer
    @Dependency(\.continuousClock) var clock

    enum SpeedValue: Double {
        case regular = 1
        case doubled = 1.5
        case half = 0.5

        var nextValue: Self {
            switch self {
                case .regular: .doubled
                case .doubled: .half
                case .half: .regular
            }
        }

        public var title: String {
            switch self {
                case .regular: "Speed x1"
                case .doubled: "Speed x2"
                case .half: "Speed x0.5"
            }
        }
    }

    enum PlayingState: Equatable {
        case play
        case pause
        case loading
        case error
    }

    enum CancelID {
        case observeAudio
        case observeAudioEnding
    }

    @ObservableState
    struct State: Equatable {
        var book: Book?
        var currentChapterIndex: Int = 0
        var currentSpeedValue: SpeedValue
        var totalDuration: TimeInterval
        var currentDuration: TimeInterval
        var playingState: PlayingState
        var currentPlayable: URL?

        public init(
            book: Book? = nil,
            currentChapterIndex: Int = 0,
            currentSpeedValue: SpeedValue,
            totalDuration: TimeInterval,
            currentDuration: TimeInterval,
            playingState: PlayingState,
            currentPlayable: URL? = nil
        ) {
            self.book = book
            self.currentChapterIndex = currentChapterIndex
            self.currentSpeedValue = currentSpeedValue
            self.totalDuration = totalDuration
            self.currentDuration = currentDuration
            self.playingState = playingState
            self.currentPlayable = currentPlayable
        }

        public var chapters: [Chapter] {
            guard let book else { return [] }

            return book.chapters
        }
    }

    enum Action {
        case currentDurationChanged(Double)
        case paybackForwardButtonPressed
        case paybackBackButtonPressed
        case nextChapterButtonPressed
        case prevChapterButtonPressed
        case adjustSpeedButtonPressed
        case playPauseButtonPressed

        case loadPlayable
        case updatePlayableCurrentTime(TimeInterval)
        case payableDownloaded(URL)
        case setupPlayableTimeline(TimeInterval)
        case playableFinished
        case errorPlayingOccured
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .playPauseButtonPressed:
                    switch state.playingState {
                        case .error:
                            return .send(.loadPlayable)
                        case .pause:
                            state.playingState = .play
                            return .merge(
                                .run { _ in
                                    await audioPlayer.play()
                                },
                                observePlayback(),
                                observePlaybackFinished()
                            )

                        case .loading:
                            return .none
                        case .play:
                            state.playingState = .pause
                            return .merge(
                                .run { send in
                                    await audioPlayer.pause()
                                },
                                .cancel(id: CancelID.observeAudio)
                            )

                    }

                case let .updatePlayableCurrentTime(newValue):
                    state.currentDuration = newValue
                    return .none

                case let .currentDurationChanged(newValue):
                    state.currentDuration = newValue
                    return .run { send in
                        await audioPlayer.playbackForward(newValue)
                    }

                case .playableFinished:
                    state.playingState = .pause
                    if state.currentChapterIndex == state.chapters.indices.last {
                        return .merge(
                            .run { send in
                                await audioPlayer.pause()
                                await audioPlayer.stopTrackingAudioEnd()
                            },
                            .cancel(id: CancelID.observeAudioEnding),
                            .cancel(id: CancelID.observeAudio)
                        )
                    }

                    return .send(.nextChapterButtonPressed)

                case .paybackForwardButtonPressed:
                    let proposedDuration = state.currentDuration + 10
                    let newValue = proposedDuration <= state.totalDuration ? proposedDuration : state.totalDuration
                    guard proposedDuration <= state.totalDuration else {
                        return .send(.nextChapterButtonPressed)
                    }

                    return .run { send in
                        await audioPlayer.playbackForward(newValue)
                    }

                case .paybackBackButtonPressed:
                    let proposedDuration = state.currentDuration - 5
                    guard proposedDuration >= 0 else {
                        return .send(.prevChapterButtonPressed)
                    }

                    return .run { send in
                        await audioPlayer.playbackForward(proposedDuration)
                    }

                case .nextChapterButtonPressed:
                    guard state.currentChapterIndex < state.chapters.count - 1 else {
                        return .none
                    }

                    state.currentChapterIndex += 1
                    return .send(.loadPlayable)

                case .prevChapterButtonPressed:
                    guard state.currentChapterIndex > 0 else {
                        return .none
                    }

                    state.currentChapterIndex -= 1
                    return .send(.loadPlayable)

                case .adjustSpeedButtonPressed:
                    let newValue = state.currentSpeedValue.nextValue
                    state.currentSpeedValue = newValue
                    return .run { send in
                        await audioPlayer.setSpeed(newValue.rawValue)
                    }

                case .loadPlayable:
                    guard let currentChapter = state.currentChapter else {
                        return .send(.errorPlayingOccured)
                    }

                    state.currentDuration = 0
                    state.currentSpeedValue = .regular
                    state.playingState = .loading
                    state.currentPlayable = nil
                    return .merge(
                        .run { send in
                            do {
                                await audioPlayer.stop()
                                let textToSpeech = try await textToSpeechClient.textToSpeech(text: currentChapter.description)
                                await send(.payableDownloaded(textToSpeech))
                            } catch {
                                await send(.errorPlayingOccured)
                            }
                        },
                        .cancel(id: CancelID.observeAudioEnding),
                        .cancel(id: CancelID.observeAudio)
                    )

                case let .payableDownloaded(url):
                    state.currentPlayable = url
                    state.playingState = .pause
                    return .run { send in
                        do {
                            let timeLine = try await audioPlayer.loadAudio(url)
                            await send(.setupPlayableTimeline(timeLine))
                        } catch {
                            await send(.errorPlayingOccured)
                        }
                    }

                case .errorPlayingOccured:
                    state.playingState = .error
                    return .run { send in
                        await audioPlayer.stop()
                    }

                case let .setupPlayableTimeline(timeline):
                    state.totalDuration = timeline
                    return .none
            }
        }
    }
}

extension PlayerFeature.State {
    public var chaptersCount: String? {
        guard !chapters.isEmpty else { return nil }

        return "key point \(currentChapterIndex + 1) of \(chapters.count)"
    }

    public var currentDurationFormatted: String {
        timeString(from: currentDuration)
    }

    public var totalDurationFormatted: String {
        timeString(from: totalDuration)
    }

    public var playbackSpeedTitle: String {
        currentSpeedValue.title
    }

    public var currentChapter: Chapter? {
        guard !chapters.isEmpty else { return nil }

        return chapters[currentChapterIndex]
    }

    public var canPlayNextChapter: Bool {
        currentChapterIndex + 1 < chapters.count
    }

    public var canPlayPrevChapter: Bool {
        currentChapterIndex - 1 >= 0
    }

    public static var empty: Self = .init(
        book: nil,
        currentChapterIndex: 0,
        currentSpeedValue: .regular,
        totalDuration: 0.1,
        currentDuration: 0,
        playingState: .pause
    )
}

private extension PlayerFeature.State {
    func timeString(from seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

private extension PlayerFeature {
    func observePlayback() -> Effect<Action> {
        return .run { send in
            for await _ in  self.clock.timer(interval: .seconds(0.1)) {
                let currentTime = await audioPlayer.currentTime()
                await send(.updatePlayableCurrentTime(currentTime))
            }
        }
        .cancellable(id: CancelID.observeAudio)
    }

    func observePlaybackFinished() -> Effect<Action> {
        return .run { send in
            for await _ in await audioPlayer.onPlaybackEnded() {
                await send(.playableFinished)
            }
        }
        .cancellable(id: CancelID.observeAudioEnding)
    }

}
