//
//  NibbleTestApp.swift
//  NibbleTest

import SwiftUI
import ComposableArchitecture

@main
struct NibbleTestApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(
                store: Store(initialState: .init()) {
                    RootFeature()
                }
            )
        }
    }
}
