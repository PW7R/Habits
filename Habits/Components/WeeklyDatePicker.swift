import SwiftUI

struct AdvancedWeeklyDatePicker: View {
    @Binding var selectedDate: Date
    @ObservedObject var habitStore: HabitStore
    
    private let calendar = Calendar.current
    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    // Use a wide range of weeks so the user can freely swipe
    private let weekRange = (-104)...(104) // ~4 years in both directions
    @State private var currentWeekOffset: Int = 0
    
    var body: some View {
        VStack(spacing: 12) {
            TabView(selection: $currentWeekOffset) {
                ForEach(weekRange, id: \.self) { offset in
                    HStack(spacing: 8) {
                        ForEach(0..<7, id: \.self) { index in
                            let date = dateFor(weekOffset: offset, dayIndex: index)
                            DayTile(
                                weekday: weekdays[index],
                                day: calendar.component(.day, from: date),
                                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                isToday: calendar.isDateInToday(date)
                            )
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    habitStore.updateSelectedDate(date)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 2)
                    .tag(offset)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 88)
        }
        .padding(.vertical, 8)
        .onAppear {
            // Ensure the pager starts on the week containing the currently selected date
            currentWeekOffset = weeksBetween(reference: Date(), and: selectedDate)
        }
        .onChange(of: selectedDate) { newValue in
            // Keep the pager aligned to selected date's week when selection changes externally
            currentWeekOffset = weeksBetween(reference: Date(), and: newValue)
        }
    }
    
    // MARK: - Helpers
    private func startOfWeek(for date: Date) -> Date {
        calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
    }
    
    private func dateFor(weekOffset: Int, dayIndex: Int) -> Date {
        let today = Date()
        let base = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: today) ?? today
        let start = startOfWeek(for: base)
        return calendar.date(byAdding: .day, value: dayIndex, to: start) ?? start
    }
    
    private func weeksBetween(reference: Date, and date: Date) -> Int {
        let refStart = startOfWeek(for: reference)
        let dateStart = startOfWeek(for: date)
        return calendar.dateComponents([.weekOfYear], from: refStart, to: dateStart).weekOfYear ?? 0
    }
}

private struct DayTile: View {
    let weekday: String
    let day: Int
    let isSelected: Bool
    let isToday: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            Text(weekday)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? .black : (isToday ? Color("Lime") : .white.opacity(0.9)))
            Text("\(day)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isSelected ? .black : (isToday ? Color("Lime") : .white))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isSelected ? Color("Lime") : Color("grayblack"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isToday && !isSelected ? Color("Lime") : Color.clear, lineWidth: 1)
        )
    }
}
