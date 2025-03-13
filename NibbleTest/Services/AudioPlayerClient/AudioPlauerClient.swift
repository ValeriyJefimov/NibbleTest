//
//  AudioPlauerClient.swift
//  NibbleTest

import ComposableArchitecture
import Foundation

extension DependencyValues {
    var audioPlayer: AudioPlayerClient {
        get { self[AudioPlayerClient.self] }
        set { self[AudioPlayerClient.self] = newValue }
    }
}

struct AudioPlayerClient {
    var loadAudio: (URL) async throws -> TimeInterval
    var play: () async -> Void
    var pause: () async -> Void
    var stop: () async -> Void
    var playbackBack: (TimeInterval) async -> Void
    var playbackForward: (TimeInterval) async -> Void
    var setSpeed: (Double) async -> Void
    var currentTime: () async -> TimeInterval
    var duration: () async -> TimeInterval
    var onPlaybackEnded: () async -> AsyncStream<Void>
    var stopTrackingAudioEnd: () async -> Void
}

extension AudioPlayerClient {
    static let testValue = AudioPlayerClient(
        loadAudio: { _ in 0},
        play: {},
        pause: {},
        stop: {},
        playbackBack: {_ in },
        playbackForward: {_ in },
        setSpeed: {_ in },
        currentTime: { 0 },
        duration: { 0 },
        onPlaybackEnded: {.finished },
        stopTrackingAudioEnd: {}
    )
}
