//
//  LiveSummaryClient.swift
//  NibbleTest
//
//  Created by Jefimov Valeriy on 12.03.2025.
//

import ComposableArchitecture
import Foundation

let apiKeyOpenAI = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
private  let systemPrompt = """
        You are a book summarizer. When given a book title, return a JSON-formatted response containing a book summary. 

        The response should include:
        - A cover image URL of the summarized book in PNG format and hd resolution. Use https://www.googleapis.com/books/v1/volumes api to get image url. Do not use wikimedia.
        - An array of chapters, where each chapter has a title and a detailed description of at least three sentences.

        Format example:
        {
            "cover": "https://actualbookcover.com/book_cover.png",
            "book_url": "https://actualbookpage.com",
            "chapters": [
                {
                    "title": "Chapter 1: Introduction",
                    "description": "This chapter introduces the main characters and sets the premise of the story. The protagonist is introduced, and the setting is described in detail. The reader gets an insight into the overarching theme of the book."
                },
                {
                    "title": "Chapter 2: Conflict Arises",
                    "description": "The protagonist faces their first major challenge. A conflict emerges that sets the story into motion, bringing tension and excitement. The stakes are raised, and the reader begins to understand the depth of the protagonist's struggles."
                }
            ]
        }
        """

extension SummaryClient {
    enum Error: Swift.Error {
        case invalidURL
        case invalidResponse
        case decodingError(String)
        case networkError(String)
    }
}

extension SummaryClient: DependencyKey {
  static let liveValue =  Self(
    bookSummary: { bookName in
        guard let apiKeyOpenAI, let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw Error.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKeyOpenAI)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")


        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": bookName]
            ],
            "temperature": 0.7
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
            throw Error.decodingError("Failed to encode request body")
        }
        request.httpBody = httpBody

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw Error.invalidResponse
            }

            guard let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let choices = responseJSON["choices"] as? [[String: Any]],
                  let message = choices.first? ["message"] as? [String: Any],
                  let content = message["content"] as? String,
                  let jsonData = content.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\\", with: "").data(using: .utf8) else {
                throw Error.decodingError("Failed to parse response")
            }

            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(Book.self, from: jsonData)

            return decodedResponse
        } catch let error as NSError {
            throw Error.networkError(error.localizedDescription)
        }

    }
  )
}
