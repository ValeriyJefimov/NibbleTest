//
//  Chapter.swift
//  NibbleTest

public struct Chapter: Equatable, Decodable {
    var title: String
    var description: String

    init(title: String, description: String) {
        self.title = title
        self.description = description
    }
}

extension Chapter {
    static func mock(title: String = "Mock Title", description: String = "Mock Description") -> Self {
        .init(title: title, description: description)
    }
}
