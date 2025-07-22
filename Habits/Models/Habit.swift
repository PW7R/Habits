import SwiftUI

enum HabitType: String, CaseIterable, Codable {
    case tracking = "tracking"
    case oneTime = "oneTime"
    
    var displayName: String {
        switch self {
        case .tracking: return "Tracking"
        case .oneTime: return "One-time"
        }
    }
    
    var example: String {
        switch self {
        case .tracking: return "Drink 8 glasses of water, Read 30 minutes"
        case .oneTime: return "Take vitamins, Make bed, Call mom"
        }
    }
}

struct Habit: Identifiable, Codable {
    var id = UUID()
    var emoji: String
    var name: String
    var colorName: String
    var dailyGoal: Int
    var currentProgress: Int = 0
    var type: HabitType = .tracking
    var isChecked: Bool = false
    
    var isCompleted: Bool {
        switch type {
        case .tracking:
            return currentProgress >= dailyGoal
        case .oneTime:
            return isChecked
        }
    }
    
    var color: Color {
        switch colorName {
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "orange": return .orange
        case "pink": return .pink
        case "red": return .red
        case "yellow": return .yellow
        case "mint": return .mint
        default: return .blue
        }
    }
    
    init(emoji: String, name: String, colorName: String, dailyGoal: Int, type: HabitType = .tracking) {
        self.emoji = emoji
        self.name = name
        self.colorName = colorName
        self.dailyGoal = dailyGoal
        self.type = type
    }
    
    // Convenience initializer from Core Data entity
    init(from entity: HabitEntity) {
        self.id = entity.id ?? UUID()
        self.emoji = entity.emoji ?? "😊"
        self.name = entity.name ?? ""
        self.colorName = entity.colorName ?? "blue"
        self.dailyGoal = Int(entity.dailyGoal)
        self.currentProgress = Int(entity.currentProgress)
        self.type = HabitType(rawValue: entity.type ?? "tracking") ?? .tracking
        self.isChecked = entity.isChecked
    }
}
