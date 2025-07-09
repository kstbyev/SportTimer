import Foundation
import UIKit
import BackgroundTasks

class BackgroundTaskManager: ObservableObject {
    static let shared = BackgroundTaskManager()
    
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    
    private init() {}
    
    func startBackgroundTask() {
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "SportTimerBackgroundTask") { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }
    
    func scheduleBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: "com.sporttimer.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 минут
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
} 