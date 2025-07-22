import SwiftUI

struct AdvancedWeeklyDatePicker: View {
    @Binding var selectedDate: Date
    @ObservedObject var habitStore: HabitStore
    
    let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    @State private var selectedDay = 1
    @State private var currentWeekDates: [Int] = []
    @State private var currentWeekOffset = 0
    @State private var moodEmojis = ["😔", "😊", "😠", "😊", "😊", "😊", "😊"]
    
    var body: some View {
        VStack(spacing: 16) {
            // Week Navigation with Month Name
            HStack {
                Button(action: { changeWeek(-1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(monthYearString(for: getCurrentWeekDate()))
                    .font(.headline)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { changeWeek(1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 20)
            
            // Days and Dates Row (Updated to sync with habitStore.selectedDate)
            HStack(spacing: 0) {
                ForEach(0..<7) { index in
                    VStack(spacing: 8) {
                        Text(weekdays[index])
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        
                        Text("\(currentWeekDates.isEmpty ? (24 + index) : currentWeekDates[index])")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(
                                // Updated to check if this date is selected AND if it's today
                                Circle()
                                    .fill(backgroundColorFor(index))
                            )
                            .cornerRadius(8)
                            .onTapGesture {
                                selectDate(at: index)
                            }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            // Remove mood emojis row since you don't want emojis
        }
        .padding(.vertical, 16)
        .onAppear {
            generateCurrentWeekDates()
        }
    }
    
    private func getCurrentWeekDate() -> Date {
        let calendar = Calendar.current
        let today = Date()
        
        guard let offsetDate = calendar.date(byAdding: .weekOfYear, value: currentWeekOffset, to: today) else {
            return today
        }
        
        return offsetDate
    }
    
    private func selectDate(at index: Int) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedDay = index
            
            // Update habitStore's selected date and reload habits
            if let newDate = getDateFor(dayIndex: index) {
                habitStore.updateSelectedDate(newDate)
            }
        }
    }
    
    private func backgroundColorFor(_ index: Int) -> Color {
        let dateForIndex = getDateFor(dayIndex: index)
        let today = Date()
        let calendar = Calendar.current
        
        if let dateForIndex = dateForIndex {
            if calendar.isDate(dateForIndex, inSameDayAs: selectedDate) {
                return .green  // Selected date
            } else if calendar.isDate(dateForIndex, inSameDayAs: today) {
                return .blue.opacity(0.3)  // Today
            }
        }
        return .clear
    }
    
    private func getDateFor(dayIndex: Int) -> Date? {
        let calendar = Calendar.current
        let today = Date()
        
        guard let offsetDate = calendar.date(byAdding: .weekOfYear, value: currentWeekOffset, to: today),
              let weekStart = calendar.dateInterval(of: .weekOfYear, for: offsetDate)?.start else {
            return nil
        }
        
        return calendar.date(byAdding: .day, value: dayIndex, to: weekStart)
    }
    
    private func changeWeek(_ direction: Int) {
        currentWeekOffset += direction
        generateCurrentWeekDates()
    }
    
    private func generateCurrentWeekDates() {
        let calendar = Calendar.current
        let today = Date()
        
        guard let offsetDate = calendar.date(byAdding: .weekOfYear, value: currentWeekOffset, to: today) else { return }
        
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: offsetDate)?.start ?? offsetDate
        
        var dates: [Int] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: weekStart) {
                let day = calendar.component(.day, from: date)
                dates.append(day)
            }
        }
        
        currentWeekDates = dates
        
        // Update selected day to match habitStore.selectedDate
        if let weekStartForCurrent = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start {
            let daysDifference = calendar.dateComponents([.day], from: weekStartForCurrent, to: selectedDate).day ?? 0
            selectedDay = daysDifference
        }
    }
    
    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}
