import SwiftUI

struct OneTimeHabitCard: View {
    let habit: Habit
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: habit.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(habit.isChecked ? habit.color : .gray)
                    .animation(.easeInOut(duration: 0.2), value: habit.isChecked)
            }
            
            Text(habit.emoji)
                .font(.title3)
            
            Text(habit.name)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .strikethrough(habit.isChecked)
                .opacity(habit.isChecked ? 0.6 : 1.0)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}
