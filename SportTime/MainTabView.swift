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
            
            TimerView(workoutViewModel: workoutViewModel)
                .tabItem {
                    Image(systemName: "timer")
                    Text("Таймер")
                }
            
            HistoryView(workoutViewModel: workoutViewModel)
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("История")
                }
            
            ProfileView(workoutViewModel: workoutViewModel, userProfile: userProfile)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Профиль")
                }
        }
        .accentColor(AppColors.primary)
    }
}

#Preview {
    MainTabView(context: PersistenceController.preview.container.viewContext)
} 