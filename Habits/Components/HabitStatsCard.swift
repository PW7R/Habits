import SwiftUI

struct HabitStatsCard: View {
    let habit: Habit
    let currentMonth: Date
    @EnvironmentObject var habitStore: HabitStore
    @State private var monthlyData: [DateProgress] = []
    
    private var completionRate: Double {
        let completedDays = monthlyData.filter { $0.isCompleted }.count
        let totalDays = monthlyData.count
        return totalDays > 0 ? Double(completedDays) / Double(totalDays) : 0
    }
    
    private var currentStreak: Int {
        var streak = 0
        let sortedData = monthlyData.sorted { $0.date > $1.date }
        
        for dayData in sortedData {
            if dayData.isCompleted {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text(habit.emoji)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(habit.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(habit.type == .tracking ? "Goal: \(habit.dailyGoal)" : "One-time daily")
                        .font(.caption)
                        .foregroundColor(Color("grayicon"))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(completionRate * 100))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("Lime"))
                    
                    Text("Complete")
                        .font(.caption)
                        .foregroundColor(Color("grayicon"))
                }
            }
            
            // GitHub-style contribution grid
            GitHubContributionGrid(
                monthlyData: monthlyData,
                color: habit.color,
                currentMonth: currentMonth
            )
            
            // Stats Summary
            HStack {
                StatItem(title: "Current Streak", value: "\(currentStreak)", color: Color("Lime"))
                
                Spacer()
                
                StatItem(title: "Best Streak", value: "\(calculateBestStreak())", color: Color("Lime"))
                
                Spacer()
                
                StatItem(title: "Total Days", value: "\(monthlyData.filter { $0.isCompleted }.count)", color: Color("Lime"))
            }
        }
        .padding(20)
        .background(Color("grayblack"))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
        .cornerRadius(16)
        .onAppear {
            generateMonthlyData()
        }
        .onChange(of: currentMonth) { _ in
            generateMonthlyData()
        }
    }
    
    private func calculateBestStreak() -> Int {
        var bestStreak = 0
        var currentStreakCount = 0
        
        for dayData in monthlyData.sorted(by: { $0.date < $1.date }) {
            if dayData.isCompleted {
                currentStreakCount += 1
                bestStreak = max(bestStreak, currentStreakCount)
            } else {
                currentStreakCount = 0
            }
        }
        
        return bestStreak
    }
    
    private func generateMonthlyData() {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        let endOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.end ?? currentMonth
        
        // Get entries for this habit in the current month
        let entries = habitStore.getHabitEntriesForMonth(habitId: habit.id, date: currentMonth)
        
        var data: [DateProgress] = []
        var currentDate = startOfMonth
        
        while currentDate < endOfMonth {
            let entry = entries.first { calendar.isDate($0.date, inSameDayAs: currentDate) }
            
            // Use real data from database
            let progress = entry?.progress ?? 0
            let isCompleted = entry?.isCompleted ?? false
            
            data.append(DateProgress(
                date: currentDate,
                progress: progress,
                goal: habit.dailyGoal,
                isCompleted: isCompleted
            ))
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        monthlyData = data
    }
}

struct DateProgress {
    let date: Date
    let progress: Int
    let goal: Int
    let isCompleted: Bool
}

struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(Color("grayicon"))
        }
    }
}
