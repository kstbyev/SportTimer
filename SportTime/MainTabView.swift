//
//  MainTabView.swift
//  SportTime
//
//  Created by Madi Sharipov on 09.07.2025.
//

import SwiftUI
import CoreData

struct MainTabView: View {
    @StateObject private var workoutViewModel: WorkoutViewModel
    @StateObject private var userProfile = UserProfile()
    
    init(context: NSManagedObjectContext) {
        self._workoutViewModel = StateObject(wrappedValue: WorkoutViewModel(context: context))
    }
    
    var body: some View {
        TabView {
            HomeView(workoutViewModel: workoutViewModel)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Главная")
                }
                .transition(Animations.slideTransition)
            
            TimerView(workoutViewModel: workoutViewModel)
                .tabItem {
                    Image(systemName: "timer")
                    Text("Таймер")
                }
                .transition(Animations.slideTransition)
            
            HistoryView(workoutViewModel: workoutViewModel)
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("История")
                }
                .transition(Animations.slideTransition)
            
            ProfileView(workoutViewModel: workoutViewModel, userProfile: userProfile)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Профиль")
                }
                .transition(Animations.slideTransition)
        }
        .accentColor(AppColors.primary)
        .animation(Animations.cardAppear, value: workoutViewModel.workouts.count)
    }
}

#Preview {
    MainTabView(context: PersistenceController.preview.container.viewContext)
} 