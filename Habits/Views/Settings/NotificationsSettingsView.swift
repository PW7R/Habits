import SwiftUI
import UserNotifications

struct NotificationsSettingsView: View {
    @Environment(\.openURL) private var openURL
    @EnvironmentObject var habitStore: HabitStore
    @State private var notificationsEnabled: Bool = true
    
    // Data source for the list
    @State private var habitsWithReminders: [HabitReminderInfo] = []
    
    // Sheet state
    @State private var selectedHabitForEditing: Habit?
    @State private var editingReminderTime: Date = Date()
    
    struct HabitReminderInfo: Identifiable {
        let id = UUID()
        let habit: Habit
        let time: Date
    }

    var body: some View {
        ZStack {
            Color("backgroundblack").ignoresSafeArea()

            List {
                Section(header: Text("Notifications").foregroundColor(.white)) {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Enable Notifications", systemImage: "bell")
                            .foregroundColor(.white)
                    }
                    .tint(Color("Lime"))
                    .onChange(of: notificationsEnabled) { enabled in
                        if enabled {
                            NotificationManager.shared.requestAuthorizationIfNeeded()
                        } else {
                            // Optionally guide user to settings if they want to fully disable,
                            // or just stop scheduling new ones.
                        }
                    }

                    Button {
                        #if canImport(UIKit)
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                        #endif
                    } label: {
                        HStack {
                            Image(systemName: "gear")
                                .foregroundColor(.white)
                            Text("Open System Settings")
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .listRowBackground(Color("grayblack"))

                Section(header: Text("Habit Reminders").foregroundColor(.white), footer: Text(habitsWithReminders.isEmpty ? "No active habit reminders" : "").foregroundColor(.gray)) {
                    ForEach(habitsWithReminders) { info in
                        Button {
                            selectedHabitForEditing = info.habit
                            editingReminderTime = info.time
                        } label: {
                            HStack {
                                Text(info.habit.emoji)
                                Text(info.habit.name)
                                    .foregroundColor(.white)
                                Spacer()
                                Text(timeString(info.time))
                                    .foregroundColor(.gray)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                        }
                    }
                    .listRowBackground(Color("grayblack"))
                }
            }
            .environment(\.defaultMinListHeaderHeight, 0)
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .listStyle(.insetGrouped)
            .tint(Color("Lime"))
        }
        .navigationTitle("Notifications")
        .onAppear { reloadReminders() }
        .sheet(item: $selectedHabitForEditing) { habit in
            HabitReminderSheet(
                habit: habit,
                remindersEnabled: true,
                reminderTime: editingReminderTime
            ) { enabled, time in
                updateReminder(for: habit, enabled: enabled, time: time)
            }
            .bottomSheetStyle()
        }
    }

    private func reloadReminders() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { reqs in
            DispatchQueue.main.async {
                var newList: [HabitReminderInfo] = []
                
                // Group requests by habit ID (prefix of identifier)
                // Identifier format: "{habitId}-{weekday}"
                // UUIDs contain dashes, so we must be careful not to break the UUID.
                // We expect the format to be "UUID-WEEKDAY", so we drop the last component.
                let grouped = Dictionary(grouping: reqs) { req -> String in
                    let parts = req.identifier.components(separatedBy: "-")
                    if parts.count > 1 {
                        return parts.dropLast().joined(separator: "-")
                    }
                    return ""
                }
                
                for (habitIdString, requests) in grouped {
                    if let habitId = UUID(uuidString: habitIdString),
                       let habit = habitStore.habits.first(where: { $0.id == habitId }),
                       let trigger = requests.first?.trigger as? UNCalendarNotificationTrigger,
                       let date = trigger.nextTriggerDate() {
                        
                        // Use the components from the trigger to construct a generic "time" date
                        // since nextTriggerDate might be tomorrow or next week.
                        let components = trigger.dateComponents
                        let time = Calendar.current.date(from: DateComponents(hour: components.hour, minute: components.minute)) ?? date
                        
                        newList.append(HabitReminderInfo(habit: habit, time: time))
                    }
                }
                
                self.habitsWithReminders = newList.sorted { $0.habit.name < $1.habit.name }
            }
        }
    }
    
    private func updateReminder(for habit: Habit, enabled: Bool, time: Date) {
        if enabled {
            // Reschedule
            NotificationManager.shared.scheduleWeeklyNotifications(habit: habit, weekdays: Array(habit.activeWeekdays), time: time)
        } else {
            // Cancel
            NotificationManager.shared.cancelNotifications(for: habit.id)
        }
        // Reload list after a short delay to allow system to update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            reloadReminders()
        }
    }
    
    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: date)
    }
}
