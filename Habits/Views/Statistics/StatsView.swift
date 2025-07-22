import SwiftUI

struct StatsView: View {
    @EnvironmentObject var habitStore: HabitStore
    @State private var currentMonth = Date()
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Statistics")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Month Navigation
            MonthNavigationView(currentMonth: $currentMonth)
            
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(habitStore.habits) { habit in
                        HabitStatsCard(habit: habit, currentMonth: currentMonth)
                            .environmentObject(habitStore)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
    }
}
