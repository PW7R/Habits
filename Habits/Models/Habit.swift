import SwiftUI
import UIKit

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

// MARK: - Color helpers for hex storage
extension Color {
    init?(hex: String) {
        var hexString = hex
        if hexString.hasPrefix("#") { hexString.removeFirst() }
        guard hexString.count == 6, let intVal = Int(hexString, radix: 16) else { return nil }
        let r = Double((intVal >> 16) & 0xFF) / 255.0
        let g = Double((intVal >> 8) & 0xFF) / 255.0
        let b = Double(intVal & 0xFF) / 255.0
        self = Color(red: r, green: g, blue: b)
    }
    
    func toHex() -> String? {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard ui.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        let ri = Int(round(r * 255))
        let gi = Int(round(g * 255))
        let bi = Int(round(b * 255))
        return String(format: "#%02X%02X%02X", ri, gi, bi)
    }
}

struct Habit: Identifiable, Codable, Hashable {
    var id = UUID()
    var emoji: String
    var name: String
    var colorName: String // hex string (e.g., #AABBCC) or named fallback
    var dailyGoal: Int
    var currentProgress: Int = 0
    var type: HabitType = .tracking
    var isChecked: Bool = false
    // 1 = Sun ... 7 = Sat
    var activeWeekdays: Set<Int> = Set(1...7)
    // For custom ordering in lists
    var sortIndex: Int = 0
    
    var isCompleted: Bool {
        switch type {
        case .tracking:
            return currentProgress >= dailyGoal
        case .oneTime:
            return isChecked
        }
    }
    
    var color: Color {
        if colorName.hasPrefix("#"), let c = Color(hex: colorName) { return c }
        switch colorName {
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "orange": return .orange
        case "pink": return .pink
        case "red": return .red
        case "yellow": return .yellow
        case "mint": return .mint
        case "Lime": return Color("Lime")
        default: return Color("Lime")
        }
    }
    
    init(emoji: String, name: String, colorName: String, dailyGoal: Int, type: HabitType = .tracking, activeWeekdays: Set<Int> = Set(1...7), sortIndex: Int = 0) {
        self.emoji = emoji
        self.name = name
        self.colorName = colorName
        self.dailyGoal = dailyGoal
        self.type = type
        self.activeWeekdays = activeWeekdays
        self.sortIndex = sortIndex
    }
    
    // Convenience initializer from Core Data entity
    init(from entity: HabitEntity) {
        self.id = entity.id ?? UUID()
        self.emoji = entity.emoji ?? "😊"
        self.name = entity.name ?? ""
        self.colorName = entity.colorName ?? "#7ED321"
        self.dailyGoal = Int(entity.dailyGoal)
        self.currentProgress = Int(entity.currentProgress)
        self.type = HabitType(rawValue: entity.type ?? "tracking") ?? .tracking
        self.isChecked = entity.isChecked
        // Parse active weekdays string like "1,2,3" (1 = Sun ... 7 = Sat). Default to all days if missing.
        if let s = entity.activeWeekdays, !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let parts = s.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            let filtered = parts.filter { (1...7).contains($0) }
            self.activeWeekdays = Set(filtered)
        } else {
            self.activeWeekdays = Set(1...7)
        }
        self.sortIndex = Int(entity.sortIndex)
    }
}

