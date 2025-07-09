//
//  TimerView.swift
//  SportTime
//
//  Created by Madi Sharipov on 09.07.2025.
//

import SwiftUI

struct TimerView: View {
    @ObservedObject var workoutViewModel: WorkoutViewModel
    @StateObject private var timerViewModel = TimerViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingSaveAlert = false
    @State private var showingDiscardAlert = false
    @State private var isSaving = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: AppConstants.standardPadding) {
                // Timer Display
                timerDisplay
                
                // Workout Type Selector
                workoutTypeSelector
                
                // Notes Section
                notesSection
                
                // Control Buttons
                controlButtons
                
                Spacer()
            }
            .padding()
            .background(AppColors.background)
            .navigationTitle("Таймер")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        if timerViewModel.elapsedTime > 0 {
                            showingDiscardAlert = true
                        } else {
                            dismiss()
                        }
                    }
                    .foregroundColor(AppColors.danger)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if timerViewModel.timerState == .completed || timerViewModel.elapsedTime > 0 {
                        Button("Сохранить") {
                            saveWorkout()
                        }
                        .foregroundColor(AppColors.success)
                    }
                }
            }
            #endif
        }
        .alert("Сохранить тренировку?", isPresented: $showingSaveAlert) {
            Button("Сохранить") {
                saveWorkout()
            }
            Button("Отмена", role: .cancel) { }
        } message: {
            Text("Тренировка будет сохранена в историю")
        }
        .alert("Отменить тренировку?", isPresented: $showingDiscardAlert) {
            Button("Отменить", role: .destructive) {
                dismiss()
            }
            Button("Продолжить", role: .cancel) { }
        } message: {
            Text("Вся информация о тренировке будет потеряна")
        }
        .overlay(
            Group {
                if isSaving {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    LoadingView()
                        .background(Color.white)
                        .cornerRadius(AppConstants.cornerRadius)
                        .shadow(color: Color.black.opacity(0.3), radius: 10)
                }
            }
        )
    }
    
    private var timerDisplay: some View {
        VStack(spacing: AppConstants.standardPadding) {
            // Circular Progress
            ZStack {
                Circle()
                    .stroke(AppColors.primary.opacity(0.2), lineWidth: 12)
                    .frame(width: 250, height: 250)
                
                Circle()
                    .trim(from: 0, to: timerViewModel.progress)
                    .stroke(
                        LinearGradient(
                            colors: [AppColors.primary, AppColors.success],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: timerViewModel.progress)
                
                VStack(spacing: 8) {
                    Text(timerViewModel.formattedTime)
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(timerViewModel.selectedWorkoutType.rawValue)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .padding()
        }
    }
    
    private var workoutTypeSelector: some View {
        VStack(alignment: .leading, spacing: AppConstants.smallPadding) {
            Text("Тип тренировки")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
            
            Button(action: {
                timerViewModel.showingWorkoutTypePicker = true
            }) {
                HStack {
                    Image(systemName: timerViewModel.selectedWorkoutType.icon)
                        .foregroundColor(timerViewModel.selectedWorkoutType.color)
                    
                    Text(timerViewModel.selectedWorkoutType.rawValue)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(AppConstants.standardPadding)
                .background(Color.white)
                .cornerRadius(AppConstants.cornerRadius)
            }
        }
        .sheet(isPresented: $timerViewModel.showingWorkoutTypePicker) {
            WorkoutTypePickerView(selectedType: $timerViewModel.selectedWorkoutType)
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.smallPadding) {
            Text("Заметки")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
            
            TextField("Добавить заметки о тренировке...", text: $timerViewModel.notes, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
        }
    }
    
    private var controlButtons: some View {
        HStack(spacing: AppConstants.standardPadding) {
            switch timerViewModel.timerState {
            case .idle:
                startButton
            case .running:
                HStack(spacing: AppConstants.standardPadding) {
                    pauseButton
                    stopButton
                }
            case .paused:
                HStack(spacing: AppConstants.standardPadding) {
                    resumeButton
                    stopButton
                }
            case .completed:
                HStack(spacing: AppConstants.standardPadding) {
                    completeButton
                    stopButton
                }
            }
        }
    }
    
    private var startButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                BackgroundTaskManager.shared.startBackgroundTask()
                timerViewModel.startTimer()
            }
        }) {
            HStack {
                Image(systemName: "play.fill")
                Text("Старт")
            }
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: AppConstants.buttonHeight)
            .background(AppColors.success)
            .cornerRadius(AppConstants.buttonCornerRadius)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var pauseButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                timerViewModel.pauseTimer()
            }
        }) {
            HStack {
                Image(systemName: "pause.fill")
                Text("Пауза")
            }
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: AppConstants.buttonHeight)
            .background(AppColors.warning)
            .cornerRadius(AppConstants.buttonCornerRadius)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var resumeButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                timerViewModel.startTimer()
            }
        }) {
            HStack {
                Image(systemName: "play.fill")
                Text("Продолжить")
            }
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: AppConstants.buttonHeight)
            .background(AppColors.success)
            .cornerRadius(AppConstants.buttonCornerRadius)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var stopButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                timerViewModel.stopTimer()
            }
        }) {
            HStack {
                Image(systemName: "stop.fill")
                Text("Стоп")
            }
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: AppConstants.buttonHeight)
            .background(AppColors.danger)
            .cornerRadius(AppConstants.buttonCornerRadius)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var completeButton: some View {
        Button(action: {
            timerViewModel.completeWorkout()
            showingSaveAlert = true
        }) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Завершить")
            }
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: AppConstants.buttonHeight)
            .background(AppColors.success)
            .cornerRadius(AppConstants.buttonCornerRadius)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private func saveWorkout() {
        isSaving = true
        
        // Имитация задержки сохранения
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            workoutViewModel.saveWorkout(
                type: timerViewModel.selectedWorkoutType.rawValue,
                duration: Int32(timerViewModel.elapsedTime),
                notes: timerViewModel.notes.isEmpty ? nil : timerViewModel.notes
            )
            BackgroundTaskManager.shared.endBackgroundTask()
            isSaving = false
            dismiss()
        }
    }
}

struct WorkoutTypePickerView: View {
    @Binding var selectedType: WorkoutType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(WorkoutType.allCases, id: \.self) { workoutType in
                Button(action: {
                    selectedType = workoutType
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: workoutType.icon)
                            .foregroundColor(workoutType.color)
                            .frame(width: 30)
                        
                        Text(workoutType.rawValue)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        if selectedType == workoutType {
                            Image(systemName: "checkmark")
                                .foregroundColor(AppColors.primary)
                        }
                    }
                }
            }
            .navigationTitle("Выберите тип тренировки")
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
    TimerView(workoutViewModel: WorkoutViewModel(context: PersistenceController.preview.container.viewContext))
} 