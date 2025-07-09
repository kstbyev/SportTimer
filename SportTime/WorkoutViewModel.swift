//
//  WorkoutViewModel.swift
//  SportTime
//
//  Created by Madi Sharipov on 09.07.2025.
//

import Foundation
import CoreData
import SwiftUI

@MainActor
class WorkoutViewModel: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var selectedFilter: WorkoutType?
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchWorkouts()
    }
    
    func fetchWorkouts() {
        Task { @MainActor in
            isLoading = true
            
            let request: NSFetchRequest<Workout> = Workout.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.date, ascending: false)]
            
            if !searchText.isEmpty {
                request.predicate = NSPredicate(format: "type CONTAINS[cd] %@ OR notes CONTAINS[cd] %@", searchText, searchText)
            }
            
            if let selectedFilter = selectedFilter {
                let filterPredicate = NSPredicate(format: "type == %@", selectedFilter.rawValue)
                if let searchPredicate = request.predicate {
                    request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [searchPredicate, filterPredicate])
                } else {
                    request.predicate = filterPredicate
                }
            }
            
            do {
                workouts = try viewContext.fetch(request)
            } catch {
                print("Error fetching workouts: \(error)")
            }
            
            isLoading = false
        }
    }
    
    func saveWorkout(type: String, duration: Int32, notes: String?) {
        Task { @MainActor in
            let workout = Workout(context: viewContext)
            workout.id = UUID()
            workout.type = type
            workout.duration = duration
            workout.date = Date()
            workout.notes = notes
            
            do {
                try viewContext.save()
                fetchWorkouts()
            } catch {
                print("Error saving workout: \(error)")
            }
        }
    }
    
    func deleteWorkout(_ workout: Workout) {
        Task { @MainActor in
            viewContext.delete(workout)
            
            do {
                try viewContext.save()
                fetchWorkouts()
            } catch {
                print("Error deleting workout: \(error)")
            }
        }
    }
    
    func getTotalWorkoutTime() -> Int {
        return workouts.reduce(0) { $0 + Int($1.duration) }
    }
    
    func getTotalWorkoutCount() -> Int {
        return workouts.count
    }
    
    func getRecentWorkouts(limit: Int = 3) -> [Workout] {
        return Array(workouts.prefix(limit))
    }
    
    func clearAllWorkouts() {
        Task { @MainActor in
            let request: NSFetchRequest<NSFetchRequestResult> = Workout.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            
            do {
                try viewContext.execute(deleteRequest)
                try viewContext.save()
                fetchWorkouts()
            } catch {
                print("Error clearing workouts: \(error)")
            }
        }
    }
} 