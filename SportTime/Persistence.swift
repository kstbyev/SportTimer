//
//  Persistence.swift
//  SportTime
//
//  Created by Madi Sharipov on 09.07.2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample workouts for preview
        let sampleWorkouts = [
            ("Strength", 1800, "Отличная тренировка!", Date().addingTimeInterval(-3600)),
            ("Cardio", 2700, "Бег в парке", Date().addingTimeInterval(-7200)),
            ("Yoga", 3600, "Утренняя йога", Date().addingTimeInterval(-86400)),
            ("Stretching", 900, "Растяжка после бега", Date().addingTimeInterval(-172800)),
            ("Other", 1200, "Плавание", Date().addingTimeInterval(-259200))
        ]
        
        for (type, duration, notes, date) in sampleWorkouts {
            let workout = Workout(context: viewContext)
            workout.id = UUID()
            workout.type = type
            workout.duration = Int32(duration)
            workout.date = date
            workout.notes = notes
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "SportTime")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
