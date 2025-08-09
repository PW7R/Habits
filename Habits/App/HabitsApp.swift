//
//  HabitsApp.swift
//  Habits
//
//  Created by Mesh on 14/07/2025.
//

import SwiftUI

@main
struct HabitsApp: App {
    @StateObject private var habitStore = HabitStore()
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(habitStore)
        }
    }
}
