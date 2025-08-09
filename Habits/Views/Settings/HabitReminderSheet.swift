import SwiftUI

struct HabitReminderSheet: View {
    let habit: Habit
    @State var remindersEnabled: Bool
    @State var reminderTime: Date
    @Environment(\.dismiss) private var dismiss
    
    // Callback to save changes: (isEnabled, time)
    var onSave: (Bool, Date) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Enable reminder", isOn: $remindersEnabled)
                        .tint(Color("Lime"))
                    
                    if remindersEnabled {
                        DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                } header: {
                    Text("Reminder for \(habit.name)")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("backgroundblack"))
            .navigationTitle("Edit Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(remindersEnabled, reminderTime)
                        dismiss()
                    }
                    .foregroundColor(Color("Lime"))
                }
            }
        }
    }
}
