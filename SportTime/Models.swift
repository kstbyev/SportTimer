//
//  Models.swift
//  SportTime
//
//  Created by Madi Sharipov on 09.07.2025.
//

import Foundation
import SwiftUI

// MARK: - Workout Types
enum WorkoutType: String, CaseIterable {
    case strength = "Strength"
    case cardio = "Cardio"
    case yoga = "Yoga"
    case stretching = "Stretching"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .strength: return "dumbbell.fill"
        case .cardio: return "heart.fill"
        case .yoga: return "figure.mind.and.body"
        case .stretching: return "figure.flexibility"
        case .other: return "figure.mixed.cardio"
        }
    }
    
    var color: Color {
        switch self {
        case .strength: return .blue
        case .cardio: return .red
        case .yoga: return .purple
        case .stretching: return .green
        case .other: return .orange
        }
    }
}

// MARK: - Timer State
enum TimerState {
    case idle
    case running
    case paused
    case completed
}

// MARK: - App Colors
struct AppColors {
    static let primary = Color(red: 0/255, green: 122/255, blue: 255/255) // #007AFF
    static let secondary = Color(red: 255/255, green: 149/255, blue: 0/255) // #FF9500
    static let success = Color(red: 52/255, green: 199/255, blue: 89/255) // #34C759
    static let warning = Color(red: 255/255, green: 149/255, blue: 0/255) // #FF9500
    static let danger = Color(red: 255/255, green: 59/255, blue: 48/255) // #FF3B30
    static let background = Color(red: 242/255, green: 242/255, blue: 247/255) // #F2F2F7
    static let textPrimary = Color.black
    static let textSecondary = Color(red: 109/255, green: 109/255, blue: 112/255) // #6D6D70
}

// MARK: - App Constants
struct AppConstants {
    static let cornerRadius: CGFloat = 12
    static let buttonCornerRadius: CGFloat = 8
    static let standardPadding: CGFloat = 16
    static let smallPadding: CGFloat = 8
    static let buttonHeight: CGFloat = 44
}

// MARK: - Time Formatter
struct TimeFormatter {
    static func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }
} 