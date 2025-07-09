//
//  SportTimeApp.swift
//  SportTime
//
//  Created by Madi Sharipov on 09.07.2025.
//

import SwiftUI

@main
struct SportTimeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
