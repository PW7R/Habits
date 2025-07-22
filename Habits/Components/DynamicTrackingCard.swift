import SwiftUI

struct DynamicTrackingCard: View {
    let habit: Habit
    let onProgressUpdate: (Int) -> Void
    @State private var currentProgress: Int
    
    init(habit: Habit, onProgressUpdate: @escaping (Int) -> Void) {
        self.habit = habit
        self.onProgressUpdate = onProgressUpdate
        self._currentProgress = State(initialValue: habit.currentProgress)
    }
    
    private var progress: Double {
        return Double(currentProgress) / Double(habit.dailyGoal)
    }
    
    private var progressPercentage: Int {
        return Int(progress * 100)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(habit.emoji)
                    .font(.title3)
                
                Text(habit.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(progressPercentage)%")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(habit.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: progress)
                
                VStack(spacing: 2) {
                    Text("\(currentProgress)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("/\(habit.dailyGoal)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            HStack(spacing: 20) {
                Button(action: {
                    let newProgress = max(0, currentProgress - 1)
                    currentProgress = newProgress
                    onProgressUpdate(newProgress)
                }) {
                    Image(systemName: "minus")
                        .foregroundColor(.gray)
                        .frame(width: 32, height: 32)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Button(action: {
                    let newProgress = min(habit.dailyGoal, currentProgress + 1)
                    currentProgress = newProgress
                    onProgressUpdate(newProgress)
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.gray.opacity(0.3))
                        .clipShape(Circle())
                }
            }
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .onChange(of: habit.currentProgress) { newValue in
            currentProgress = newValue
        }
    }
}
