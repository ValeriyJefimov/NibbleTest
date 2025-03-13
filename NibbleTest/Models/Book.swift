//
//  Book.swift
//  NibbleTest

import Foundation

public struct Book: Equatable, Decodable {
    var cover: URL
    var chapters: [Chapter]

   init(cover: URL, chapters: [Chapter]) {
        self.cover = cover
        self.chapters = chapters
    }
}

extension Book {
    static func mock(
        cover: URL = URL(string: "https://a.storyblok.com/f/181188/720x1080/0d5afbeb5b/you-are-a-badass-at-making-money.jpg")!,
        chapters: [Chapter] = [.mock()]
    ) -> Self {
        .init(cover: cover, chapters: chapters)
    }
}
