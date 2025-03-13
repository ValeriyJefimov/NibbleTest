//
//  SummaryClient.swift
//  NibbleTest

import ComposableArchitecture
import Foundation

@DependencyClient
struct SummaryClient {
    var bookSummary: @Sendable (_ bookName: String) async throws -> Book
}

extension SummaryClient: TestDependencyKey {
  static let previewValue = Self(
    bookSummary: { _ in .mock() }
  )

  static let testValue = Self()
}

extension DependencyValues {
  var summaryClient: SummaryClient {
    get { self[SummaryClient.self] }
    set { self[SummaryClient.self] = newValue }
  }
}
