//
//  HabitsApp.swift
//  Habits
//
//  Created by Mesh on 14/07/2025.
//

import SwiftUI
import UserNotifications

@main
struct HabitsApp: App {
    @StateObject private var habitStore = HabitStore()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(habitStore)
            } else {
                OnboardingView()
            }
        }
    }
}
