//
//  SportTimeApp.swift
//  SportTime
//
//  Created by Madi Sharipov on 09.07.2025.
//

import SwiftUI
import BackgroundTasks

@main
struct SportTimeApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        setupBackgroundTasks()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView(context: persistenceController.container.viewContext)
        }
    }
    
    private func setupBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.sporttimer.refresh", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        // Schedule the next refresh
        scheduleAppRefresh()
        
        // Perform any background work here
        task.setTaskCompleted(success: true)
    }
    
    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.sporttimer.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
}
