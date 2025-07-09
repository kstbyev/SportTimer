//
//  ProfileView.swift
//  SportTime
//
//  Created by Madi Sharipov on 09.07.2025.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var workoutViewModel: WorkoutViewModel
    @ObservedObject var userProfile: UserProfile
    @State private var showingClearDataAlert = false
    @State private var showingAboutSheet = false
    @State private var showingImagePicker = false
    @State private var showingCameraPicker = false
    @State private var showingAvatarOptions = false
    @State private var selectedImage: UIImage?
    @State private var showingEditName = false
    @State private var editingName = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppConstants.standardPadding) {
                    // Profile Header
                    profileHeader
                    
                    // Statistics Section
                    statisticsSection
                    
                    // Settings Section
                    settingsSection
                    
                    // About Section
                    aboutSection
                }
                .padding()
            }
            .background(AppColors.background)
            .navigationTitle("Профиль")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
        .alert("Очистить все данные?", isPresented: $showingClearDataAlert) {
            Button("Очистить", role: .destructive) {
                workoutViewModel.clearAllWorkouts()
            }
            Button("Отмена", role: .cancel) { }
        } message: {
            Text("Это действие нельзя отменить. Все тренировки будут удалены.")
        }
        .sheet(isPresented: $showingAboutSheet) {
            AboutView()
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showingCameraPicker) {
            CameraImagePicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { _, newImage in
            if let image = newImage {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    userProfile.updateAvatar(image)
                }
            }
        }
        .alert("Изменить имя", isPresented: $showingEditName) {
            TextField("Введите имя", text: $editingName)
            Button("Сохранить") {
                if !editingName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    userProfile.updateUserName(editingName.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
            Button("Отмена", role: .cancel) { }
        } message: {
            Text("Введите новое имя пользователя")
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: AppConstants.standardPadding) {
            // Avatar
            Button(action: {
                #if os(iOS)
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                #endif
                showingAvatarOptions = true
            }) {
                ZStack {
                    if let avatarImage = userProfile.avatarImage {
                        Image(uiImage: avatarImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(AppColors.primary, lineWidth: 2)
                            )
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(AppColors.primary)
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Edit icon
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "camera.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .background(AppColors.primary)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // User Info
            VStack(spacing: 4) {
                Button(action: {
                    #if os(iOS)
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    #endif
                    editingName = userProfile.userName
                    showingEditName = true
                }) {
                    HStack {
                        Text(userProfile.userName)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Image(systemName: "pencil")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Text(userProfile.userStatus)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(AppConstants.standardPadding)
        .background(Color.white)
        .cornerRadius(AppConstants.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .actionSheet(isPresented: $showingAvatarOptions) {
            ActionSheet(
                title: Text("Выберите фото"),
                message: Text("Откуда хотите выбрать фото?"),
                buttons: [
                    .default(Text("Галерея")) {
                        showingImagePicker = true
                    },
                    .default(Text("Камера")) {
                        #if os(iOS)
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            showingCameraPicker = true
                        }
                        #endif
                    },
                    .destructive(Text("Удалить фото")) {
                        userProfile.clearAvatar()
                    },
                    .cancel()
                ]
            )
        }
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.smallPadding) {
            Text("Статистика")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AppConstants.smallPadding) {
                StatisticCard(
                    title: "Всего тренировок",
                    value: "\(workoutViewModel.getTotalWorkoutCount())",
                    icon: "figure.run",
                    color: AppColors.primary
                )
                
                StatisticCard(
                    title: "Общее время",
                    value: TimeFormatter.formatTime(workoutViewModel.getTotalWorkoutTime()),
                    icon: "clock.fill",
                    color: AppColors.success
                )
                
                StatisticCard(
                    title: "Средняя длительность",
                    value: averageWorkoutTime,
                    icon: "timer",
                    color: AppColors.secondary
                )
                
                StatisticCard(
                    title: "Любимый тип",
                    value: favoriteWorkoutType,
                    icon: "heart.fill",
                    color: AppColors.warning
                )
            }
        }
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.smallPadding) {
            Text("Настройки")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "speaker.wave.2.fill",
                    title: "Звуки таймера",
                    subtitle: "Включены",
                    action: { }
                )
                
                Divider()
                    .padding(.leading, 56)
                
                SettingsRow(
                    icon: "bell.fill",
                    title: "Уведомления",
                    subtitle: "Включены",
                    action: { }
                )
                
                Divider()
                    .padding(.leading, 56)
                
                SettingsRow(
                    icon: "trash.fill",
                    title: "Очистить данные",
                    subtitle: "Удалить все тренировки",
                    action: { showingClearDataAlert = true }
                )
            }
            .background(Color.white)
            .cornerRadius(AppConstants.cornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.smallPadding) {
            Text("О приложении")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "info.circle.fill",
                    title: "О SportTimer",
                    subtitle: "Версия 1.0.0",
                    action: { showingAboutSheet = true }
                )
                
                Divider()
                    .padding(.leading, 56)
                
                SettingsRow(
                    icon: "doc.text.fill",
                    title: "Политика конфиденциальности",
                    subtitle: "Читать",
                    action: { }
                )
                
                Divider()
                    .padding(.leading, 56)
                
                SettingsRow(
                    icon: "hand.raised.fill",
                    title: "Условия использования",
                    subtitle: "Читать",
                    action: { }
                )
            }
            .background(Color.white)
            .cornerRadius(AppConstants.cornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
    
    private var averageWorkoutTime: String {
        let workouts = workoutViewModel.workouts
        guard !workouts.isEmpty else { return "00:00" }
        
        let totalTime = workouts.reduce(0) { $0 + Int($1.duration) }
        let averageTime = totalTime / workouts.count
        return TimeFormatter.formatTime(averageTime)
    }
    
    private var favoriteWorkoutType: String {
        let workouts = workoutViewModel.workouts
        guard !workouts.isEmpty else { return "Нет данных" }
        
        let typeCounts = workouts.reduce(into: [String: Int]()) { counts, workout in
            let type = workout.type ?? "Unknown"
            counts[type, default: 0] += 1
        }
        
        let favorite = typeCounts.max(by: { $0.value < $1.value })?.key ?? "Нет данных"
        return favorite
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.smallPadding) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
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

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppConstants.smallPadding) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.primary)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(AppConstants.standardPadding)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppConstants.standardPadding) {
                    // App Icon
                    Image(systemName: "figure.run.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(AppColors.primary)
                    
                    // App Info
                    VStack(spacing: AppConstants.smallPadding) {
                        Text("SportTimer")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Версия 1.0.0")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text("Простой трекер тренировок с таймером для отслеживания и сохранения спортивных активностей.")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, AppConstants.smallPadding)
                    }
                    
                    // Features
                    VStack(alignment: .leading, spacing: AppConstants.smallPadding) {
                        Text("Возможности:")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        FeatureRow(icon: "timer", text: "Таймер тренировок с точностью до секунды")
                        FeatureRow(icon: "chart.bar.fill", text: "Детальная статистика тренировок")
                        FeatureRow(icon: "magnifyingglass", text: "Поиск и фильтрация истории")
                        FeatureRow(icon: "icloud.fill", text: "Сохранение данных в Core Data")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(AppConstants.cornerRadius)
                }
                .padding()
            }
            .background(AppColors.background)
            .navigationTitle("О приложении")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            #endif
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: AppConstants.smallPadding) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppColors.primary)
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
        }
    }
}

#Preview {
    ProfileView(
        workoutViewModel: WorkoutViewModel(context: PersistenceController.preview.container.viewContext),
        userProfile: UserProfile()
    )
} 