//
//  TextToSpeechClient.swift
//  NibbleTest

import ComposableArchitecture
import Foundation

@DependencyClient
struct TextToSpeechClient {
    var textToSpeech: @Sendable (_ text: String) async throws -> URL
}

extension TextToSpeechClient: TestDependencyKey {
  static let previewValue = Self(
    textToSpeech: { _ in URL(string: "google.com")! }
  )

  static let testValue = Self()
}

extension DependencyValues {
  var textToSpeechClient: TextToSpeechClient {
    get { self[TextToSpeechClient.self] }
    set { self[TextToSpeechClient.self] = newValue }
  }
}
