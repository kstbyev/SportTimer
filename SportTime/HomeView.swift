//
//  HomeView.swift
//  SportTime
//
//  Created by Madi Sharipov on 09.07.2025.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var workoutViewModel: WorkoutViewModel
    @State private var showingTimer = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppConstants.standardPadding) {
                    // Header Section
                    headerSection
                    
                    // Start Workout Button
                    startWorkoutButton
                    
                    // Recent Workouts Section
                    recentWorkoutsSection
                }
                .padding()
            }
            .background(AppColors.background)
            .navigationTitle("SportTimer")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
        .sheet(isPresented: $showingTimer) {
            TimerView(workoutViewModel: workoutViewModel)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.smallPadding) {
            Text("Привет! 👋")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            Text("Готов к новой тренировке?")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
            
            // Statistics Cards
            HStack(spacing: AppConstants.smallPadding) {
                StatCard(
                    title: "Всего тренировок",
                    value: "\(workoutViewModel.getTotalWorkoutCount())",
                    icon: "figure.run",
                    color: AppColors.primary
                )
                
                StatCard(
                    title: "Общее время",
                    value: TimeFormatter.formatTime(workoutViewModel.getTotalWorkoutTime()),
                    icon: "clock.fill",
                    color: AppColors.success
                )
            }
        }
    }
    
    private var startWorkoutButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showingTimer = true
            }
        }) {
            VStack(spacing: AppConstants.smallPadding) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.white)
                
                Text("Начать тренировку")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(AppConstants.cornerRadius)
            .shadow(color: AppColors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var recentWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.smallPadding) {
            Text("Последние тренировки")
                .font(.system(size: 20, weightz
                    
                    efjb.semibold))
                .foregroundColor(AppColors.textPrimary)
            
            if workoutViewModel.workouts.isEmpty {
                emptyWorkoutsView
            } else {
                LazyVStack(spacing: AppConstants.smallPadding) {
                    ForEach(Array(workoutViewModel.getRecentWorkouts().enumerated()), id: \.element.id) { index, workout in
                        AnimatedCardView {
                            WorkoutCard(workout: workout)
                        }
                        .animation(Animations.cardAppear.delay(Double(index) * 0.1), value: workoutViewModel.workouts.count)
                    }
                }
            }
        }
    }
    
    private var emptyWorkoutsView: some View {
        VStack(spacing: AppConstants.smallPadding) {
            Image(systemName: "figure.run")
                .font(.system(size: 48))
                .foregroundColor(AppColors.textSecondary)
            
            Text("Нет тренировок")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
            
            Text("Начните свою первую тренировку!")
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppConstants.standardPadding)
        .background(Color.white)
        .cornerRadius(AppConstants.cornerRadius)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.smallPadding) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(AppConstants.standardPadding)
        .background(Color.white)
        .cornerRadius(AppConstants.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct WorkoutCard: View {
    let workout: Workout
    
    var body: some View {
        HStack(spacing: AppConstants.smallPadding) {
            // Workout Type Icon
            Image(systemName: getWorkoutTypeIcon())
                .font(.system(size: 24))
                .foregroundColor(getWorkoutTypeColor())
                .frame(width: 40, height: 40)
                .background(getWorkoutTypeColor().opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.type ?? "Unknown")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                if let notes = workout.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(TimeFormatter.formatTime(Int(workout.duration)))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(formatDate(workout.date))
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(AppConstants.standardPadding)
        .background(Color.white)
        .cornerRadius(AppConstants.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func getWorkoutTypeIcon() -> String {
        guard let typeString = workout.type else { return "figure.mixed.cardio" }
        return WorkoutType(rawValue: typeString)?.icon ?? "figure.mixed.cardio"
    }
    
    private func getWorkoutTypeColor() -> Color {
        guard let typeString = workout.type else { return AppColors.primary }
        return WorkoutType(rawValue: typeString)?.color ?? AppColors.primary
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(Animations.buttonPress, value: configuration.isPressed)
    }
}

#Preview {
    HomeView(workoutViewModel: WorkoutViewModel(context: PersistenceController.preview.container.viewContext))
} 
