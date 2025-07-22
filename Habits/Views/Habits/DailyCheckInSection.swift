import SwiftUI

struct DailyCheckInSection: View {
    @EnvironmentObject var habitStore: HabitStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Daily check-in")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(habitStore.completedHabitsCount)/\(habitStore.totalHabitsCount)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Tracking Habits Grid
            if !habitStore.trackingHabits.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(habitStore.trackingHabits) { habit in
                        DynamicTrackingCard(
                            habit: habit,
                            onProgressUpdate: { newProgress in
                                habitStore.updateHabitProgress(
                                    habitId: habit.id,
                                    newProgress: newProgress
                                )
                            }
                        )
                    }
                }
            }
            
            // One-time Habits List
            if !habitStore.oneTimeHabits.isEmpty {
                VStack(spacing: 8) {
                    ForEach(habitStore.oneTimeHabits) { habit in
                        OneTimeHabitCard(habit: habit) {
                            habitStore.toggleOneTimeHabit(habitId: habit.id)
                        }
                    }
                }
                .padding(.top, habitStore.trackingHabits.isEmpty ? 0 : 16)
            }
        }
    }
}
