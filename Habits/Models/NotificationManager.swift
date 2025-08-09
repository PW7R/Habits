import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}
    
    private let center = UNUserNotificationCenter.current()
    
    func requestAuthorizationIfNeeded(completion: ((Bool) -> Void)? = nil) {
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    completion?(granted)
                }
            case .authorized, .provisional, .ephemeral:
                completion?(true)
            default:
                completion?(false)
            }
        }
    }
    
    func scheduleWeeklyNotifications(habit: Habit, weekdays: [Int], time: Date) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)
        
        // Clear previously scheduled notifications for this habit
        cancelNotifications(for: habit.id)
        
        let uniqueDays = Set(weekdays)
        for weekday in uniqueDays {
            var components = DateComponents()
            components.weekday = weekday // 1 = Sun ... 7 = Sat
            components.hour = hour
            components.minute = minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let content = UNMutableNotificationContent()
            content.title = "Habit reminder"
            content.body = "\(habit.emoji) \(habit.name)"
            content.sound = .default
            
            let identifier = notificationIdentifier(for: habit.id, weekday: weekday)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            center.add(request)
        }
    }
    
    func cancelNotifications(for habitId: UUID) {
        let ids = (1...7).map { notificationIdentifier(for: habitId, weekday: $0) }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }
    
    private func notificationIdentifier(for habitId: UUID, weekday: Int) -> String {
        return "\(habitId.uuidString)-\(weekday)"
    }
}


