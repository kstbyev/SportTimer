//
//  TimerViewModel.swift
//  SportTime
//
//  Created by Madi Sharipov on 09.07.2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class TimerViewModel: ObservableObject {
    @Published var elapsedTime: Int = 0
    @Published var timerState: TimerState = .idle
    @Published var selectedWorkoutType: WorkoutType = .strength
    @Published var notes: String = ""
    @Published var showingWorkoutTypePicker = false
    
    private var timer: Timer?
    private var startTime: Date?
    private var pausedTime: Int = 0
    
    var formattedTime: String {
        TimeFormatter.formatTime(elapsedTime)
    }
    
    var progress: Double {
        // For circular progress, we'll use a 60-minute workout as reference
        let maxTime = 60 * 60 // 1 hour in seconds
        return min(Double(elapsedTime) / Double(maxTime), 1.0)
    }
    
    func startTimer() {
        guard timerState != .running else { return }
        
        if timerState == .paused {
            // Resume from paused state
            startTime = Date().addingTimeInterval(-Double(pausedTime))
        } else {
            // Start new timer
            startTime = Date()
            pausedTime = 0
        }
        
        timerState = .running
        startTimerUpdates()
    }
    
    func pauseTimer() {
        guard timerState == .running else { return }
        
        timerState = .paused
        pausedTime = elapsedTime
        stopTimerUpdates()
    }
    
    func stopTimer() {
        timerState = .idle
        elapsedTime = 0
        pausedTime = 0
        startTime = nil
        stopTimerUpdates()
    }
    
    func completeWorkout() {
        timerState = .completed
        stopTimerUpdates()
    }
    
    private func startTimerUpdates() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                await self.updateElapsedTime()
            }
        }
    }
    
    private func stopTimerUpdates() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateElapsedTime() async {
        guard let startTime = startTime else { return }
        
        let currentTime = Date()
        elapsedTime = Int(currentTime.timeIntervalSince(startTime)) + pausedTime
    }
    
    func saveWorkout() {
        guard elapsedTime > 0 else { return }
        
        // This will be called from the main app to save the workout
        // The actual saving logic is in WorkoutViewModel
    }
    
    func resetTimer() {
        stopTimer()
        notes = ""
        selectedWorkoutType = .strength
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
} 
