//
//  Baby_FairytaleApp.swift
//  Baby Fairytale
//
//  Created by Mustafa Said Tozluoglu on 21.11.2025.
//

import SwiftUI

@main
struct Baby_FairytaleApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
