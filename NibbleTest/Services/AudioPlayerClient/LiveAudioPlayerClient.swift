//
//  LiveAudioPlayerClient.swift
//  NibbleTest

import ComposableArchitecture
import Foundation

extension AudioPlayerClient: DependencyKey {
    static let liveValue = AudioPlayerClient(
        loadAudio: { url in
            try await AudioPlayerManager.shared.loadAudio(from: url)
        },
        play: {
            await MainActor.run {
                AudioPlayerManager.shared.play()
            }
        },
        pause: {
            await MainActor.run {
                AudioPlayerManager.shared.pause()
            }
        },
        stop: {
            await MainActor.run {
                AudioPlayerManager.shared.stop()
            }
        },
        playbackBack: { time in
            await MainActor.run {
                AudioPlayerManager.shared.seek(by: time)
            }
        },
        playbackForward: { time in
            await MainActor.run {
                AudioPlayerManager.shared.seek(to: time)
            }
        },
        setSpeed: { speed in
            await MainActor.run {
                AudioPlayerManager.shared.setSpeed(speed)
            }
        },
        currentTime: {
            await MainActor.run {
                AudioPlayerManager.shared.currentTime()
            }
        },
        duration: {
            await MainActor.run {
                AudioPlayerManager.shared.duration()
            }
        },
        onPlaybackEnded: {
            AudioPlayerManager.shared.playbackFinishedStream
        },
        stopTrackingAudioEnd: {
            AudioPlayerManager.shared.stopTrackingFinishedStream()
        }
    )
}
