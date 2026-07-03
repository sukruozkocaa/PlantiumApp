//
//  BitkiAppApp.swift
//  BitkiApp
//
//  Created by Şükrü on 3.07.2026.
//

import SwiftUI
import SwiftData

@main
struct BitkiAppApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [Plant.self, PlantSnapshot.self])
    }
}
