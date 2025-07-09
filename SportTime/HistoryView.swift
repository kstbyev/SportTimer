//
//  HistoryView.swift
//  SportTime
//
//  Created by Madi Sharipov on 09.07.2025.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var workoutViewModel: WorkoutViewModel
    @State private var searchText = ""
    @State private var selectedFilter: WorkoutType?
    @State private var showingFilterSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Bar
                searchAndFilterBar
                
                // Workouts List
                workoutsList
            }
            .background(AppColors.background)
            .navigationTitle("История")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .searchable(text: $searchText, prompt: "Поиск тренировок...")
            .onChange(of: searchText) { _, _ in
                workoutViewModel.searchText = searchText
                workoutViewModel.fetchWorkouts()
            }
        }
        .sheet(isPresented: $showingFilterSheet) {
            FilterView(selectedFilter: $selectedFilter) {
                workoutViewModel.selectedFilter = selectedFilter
                workoutViewModel.fetchWorkouts()
            }
        }
    }
    
    private var searchAndFilterBar: some View {
        HStack(spacing: AppConstants.smallPadding) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.textSecondary)
                
                TextField("Поиск...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(AppConstants.smallPadding)
            .background(Color.white)
            .cornerRadius(AppConstants.buttonCornerRadius)
            
            // Filter Button
            Button(action: {
                showingFilterSheet = true
            }) {
                HStack {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                    Text(selectedFilter?.rawValue ?? "Все")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(selectedFilter != nil ? AppColors.primary : AppColors.textSecondary)
                .padding(.horizontal, AppConstants.smallPadding)
                .padding(.vertical, 8)
                .background(selectedFilter != nil ? AppColors.primary.opacity(0.1) : Color.white)
                .cornerRadius(AppConstants.buttonCornerRadius)
            }
        }
        .padding()
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var workoutsList: some View {
        Group {
            if workoutViewModel.isLoading {
                ProgressView("Загрузка...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if workoutViewModel.workouts.isEmpty {
                emptyStateView
            } else {
                List {
                                            ForEach(groupedWorkouts.keys.sorted(by: >), id: \.self) { date in
                            Section(header: dateHeader(for: date)) {
                                ForEach(Array((groupedWorkouts[date] ?? []).enumerated()), id: \.element.id) { index, workout in
                                    AnimatedCardView {
                                        WorkoutHistoryRow(workout: workout) {
                                            deleteWorkout(workout)
                                        }
                                    }
                                    .animation(Animations.cardAppear.delay(Double(index) * 0.05), value: workoutViewModel.workouts.count)
                                }
                            }
                        }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: AppConstants.standardPadding) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 64))
                .foregroundColor(AppColors.textSecondary)
            
            Text("Нет тренировок")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            Text("Начните тренировку, чтобы увидеть её в истории")
                .font(.system(size: 16))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var groupedWorkouts: [Date: [Workout]] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: workoutViewModel.workouts) { workout in
            calendar.startOfDay(for: workout.date ?? Date())
        }
        return grouped
    }
    
    private func dateHeader(for date: Date) -> some View {
        HStack {
            Text(formatDate(date))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            if let workouts = groupedWorkouts[date] {
                Text("\(workouts.count) тренировок")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Сегодня"
        } else if calendar.isDateInYesterday(date) {
            return "Вчера"
        } else {
            formatter.dateFormat = "dd MMMM yyyy"
            formatter.locale = Locale(identifier: "ru_RU")
            return formatter.string(from: date)
        }
    }
    
    private func deleteWorkout(_ workout: Workout) {
        withAnimation {
            workoutViewModel.deleteWorkout(workout)
        }
    }
}

struct WorkoutHistoryRow: View {
    let workout: Workout
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: AppConstants.smallPadding) {
            // Workout Type Icon
            Image(systemName: getWorkoutTypeIcon())
                .font(.system(size: 20))
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
                        .lineLimit(2)
                }
                
                Text(formatTime(workout.date))
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(TimeFormatter.formatTime(Int(workout.duration)))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Длительность")
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        }
    }
    
    private func getWorkoutTypeIcon() -> String {
        guard let typeString = workout.type else { return "figure.mixed.cardio" }
        return WorkoutType(rawValue: typeString)?.icon ?? "figure.mixed.cardio"
    }
    
    private func getWorkoutTypeColor() -> Color {
        guard let typeString = workout.type else { return AppColors.primary }
        return WorkoutType(rawValue: typeString)?.color ?? AppColors.primary
    }
    
    private func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct FilterView: View {
    @Binding var selectedFilter: WorkoutType?
    let onApply: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button("Все тренировки") {
                        selectedFilter = nil
                        onApply()
                        dismiss()
                    }
                    .foregroundColor(selectedFilter == nil ? AppColors.primary : AppColors.textPrimary)
                }
                
                Section("Типы тренировок") {
                    ForEach(WorkoutType.allCases, id: \.self) { workoutType in
                        Button(workoutType.rawValue) {
                            selectedFilter = workoutType
                            onApply()
                            dismiss()
                        }
                        .foregroundColor(selectedFilter == workoutType ? AppColors.primary : AppColors.textPrimary)
                    }
                }
            }
            .navigationTitle("Фильтр")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            #endif
        }
    }
}

#Preview {
    HistoryView(workoutViewModel: WorkoutViewModel(context: PersistenceController.preview.container.viewContext))
} 