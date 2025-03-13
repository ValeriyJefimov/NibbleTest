//
//  LiveTextToSpeechClient.swift
//  NibbleTest

import ComposableArchitecture
import Foundation

let apiKeyGoogle = ProcessInfo.processInfo.environment["GOOGLE_API_KEY"]

enum TextToSpeechClientError: Swift.Error {
    case invalidURL
    case invalidResponse
    case decodingError(String)
    case networkError(String)
    case audioProcessingError(String)
}

extension TextToSpeechClient: DependencyKey {
    static let liveValue = Self { text in
        guard
            let apiKeyGoogle,
            let url = URL(string: "https://texttospeech.googleapis.com/v1/text:synthesize?key=\(apiKeyGoogle)")
        else {
            throw TextToSpeechClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "input": ["text": text],
            "voice": [
                "languageCode": "en-US",
                "name": "en-US-Wavenet-D"
            ],
            "audioConfig": ["audioEncoding": "MP3"]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TextToSpeechClientError.invalidResponse
        }

        do {
            let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            guard let audioContent = responseJSON?["audioContent"] as? String,
                  let audioData = Data(base64Encoded: audioContent) else {
                throw TextToSpeechClientError.decodingError("Failed to decode audio content.")
            }

            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("speech.mp3")
            try audioData.write(to: tempURL)

            return tempURL
        } catch {
            throw TextToSpeechClientError.audioProcessingError(error.localizedDescription)
        }
    }
}
