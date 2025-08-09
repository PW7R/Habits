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
        NavigationStack {
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
            
            // Remove MonthNavigationView per request
            
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(habitStore.habits) { habit in
                        NavigationLink(value: habit) {
                            HabitStatsCard(habit: habit, currentMonth: currentMonth)
                                .environmentObject(habitStore)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                
            }
            .scrollIndicators(.hidden)
        }
        .background(Color("backgroundblack").ignoresSafeArea())
        .navigationDestination(for: Habit.self) { habit in
            HabitStatsDetail(habit: habit)
                .environmentObject(habitStore)
        }
        }
    }
}

// MARK: - Habit Stats Detail Page
struct HabitStatsDetail: View {
    let habit: Habit
    @EnvironmentObject var habitStore: HabitStore
    @State private var showingEdit = false

    private var allEntries: [DateProgress] { habitStore.getAllHabitEntries(habitId: habit.id) }
    private var last365Entries: [DateProgress] { habitStore.getEntriesForLast365Days(habitId: habit.id) }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AllTimeStatsCard(habit: habit, entries: allEntries)
                Last365DaysCard(entries: last365Entries, color: habit.color)
                YearOverviewCard(habit: habit)
            }
            .padding(20)
            .background(Color("backgroundblack").ignoresSafeArea())
        }
        .scrollIndicators(.hidden)
        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") { showingEdit = true }
                    .foregroundColor(.white)
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddHabitView()
                .environmentObject(habitStore)
                .bottomSheetStyle()
        }
    }
}

private struct AllTimeStatsCard: View {
    let habit: Habit
    let entries: [DateProgress]

    private var startDate: Date { entries.map { $0.date }.min() ?? Date() }
    private var totalDaysSinceStart: Int {
        let cal = Calendar.current
        let s = cal.startOfDay(for: startDate)
        let e = cal.startOfDay(for: Date())
        return (cal.dateComponents([.day], from: s, to: e).day ?? 0) + 1
    }
    private var completedDaysCount: Int { entries.filter { $0.isCompleted }.count }
    private var completionRatePercent: Int {
        guard totalDaysSinceStart > 0 else { return 0 }
        return Int(round((Double(completedDaysCount) / Double(totalDaysSinceStart)) * 100.0))
    }
    private var currentStreak: Int {
        let cal = Calendar.current
        let dates = Set(entries.filter { $0.isCompleted }.map { cal.startOfDay(for: $0.date) })
        var streak = 0
        var cursor = cal.startOfDay(for: Date())
        while dates.contains(cursor) {
            streak += 1
            cursor = cal.date(byAdding: .day, value: -1, to: cursor) ?? cursor
        }
        return streak
    }
    private var longestStreak: Int {
        let cal = Calendar.current
        let sorted = entries.sorted { $0.date < $1.date }
        var best = 0
        var current = 0
        var previousDay: Date? = nil
        for entry in sorted where entry.isCompleted {
            let day = cal.startOfDay(for: entry.date)
            if let prev = previousDay, let nextOfPrev = cal.date(byAdding: .day, value: 1, to: prev), cal.isDate(day, inSameDayAs: nextOfPrev) {
                current += 1
            } else {
                current = 1
            }
            previousDay = day
            best = max(best, current)
        }
        return best
    }
    private var startDateString: String {
        let f = DateFormatter(); f.dateFormat = "dd MMM yyyy"; return f.string(from: startDate)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All-time stats").font(.headline).foregroundColor(.white)
            VStack(alignment: .leading, spacing: 10) {
                HStack { Text("Current Streak").foregroundColor(.gray); Spacer(); Text("\(currentStreak) days").foregroundColor(.white) }
                HStack { Text("Longest Streak").foregroundColor(.gray); Spacer(); Text("\(longestStreak) day\(longestStreak == 1 ? "" : "s")").foregroundColor(.white) }
                HStack { Text("Completion").foregroundColor(.gray); Spacer(); Text("\(completionRatePercent) % (\(completedDaysCount) of \(totalDaysSinceStart) days)").foregroundColor(.white) }
                HStack { Text("Start date").foregroundColor(.gray); Spacer(); Text(startDateString).foregroundColor(.white) }
            }
            .font(.subheadline)
        }
        .padding(16)
        .background(Color("grayblack"))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.2), lineWidth: 0.5))
        .cornerRadius(16)
    }
}

private struct Last365DaysCard: View {
    let entries: [DateProgress]
    let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 365 days").font(.headline).foregroundColor(.white)
            ContributionGrid365(entries: entries, color: color)
        }
        .padding(16)
        .background(Color("grayblack"))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.2), lineWidth: 0.5))
        .cornerRadius(16)
    }
}

private struct ContributionGrid365: View {
    let entries: [DateProgress]
    let color: Color
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.fixed(12), spacing: 3, alignment: .center), count: 21)
    private var dayMap: Set<Date> { Set(entries.filter { $0.isCompleted }.map { calendar.startOfDay(for: $0.date) }) }
    private var days: [Date] {
        let end = calendar.startOfDay(for: Date())
        let start = calendar.date(byAdding: .day, value: -364, to: end) ?? end
        var list: [Date] = []
        var cursor = start
        while cursor <= end { list.append(cursor); cursor = calendar.date(byAdding: .day, value: 1, to: cursor) ?? cursor }
        return list
    }
    var body: some View {
        LazyVGrid(columns: columns, alignment: .center, spacing: 3) {
            ForEach(days, id: \.self) { day in
                let completed = dayMap.contains(calendar.startOfDay(for: day))
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(completed ? color : Color.gray.opacity(0.25))
                    .frame(width: 12, height: 12)
                    .overlay(RoundedRectangle(cornerRadius: 3, style: .continuous).stroke(Color.gray.opacity(0.25), lineWidth: 0.3))
            }
        }
    }
}

private struct YearOverviewCard: View {
    let habit: Habit
    @EnvironmentObject var habitStore: HabitStore
    private let calendar = Calendar.current

    // Year helpers
    private var yearStart: Date { calendar.date(from: calendar.dateComponents([.year], from: Date())) ?? Date() }
    private var yearEnd: Date { calendar.date(byAdding: .year, value: 1, to: yearStart) ?? yearStart }
    private var months: [Date] { (0..<12).compactMap { calendar.date(byAdding: .month, value: $0, to: yearStart) } }

    // Stats (YTD)
    private var yearEntries: [DateProgress] {
        let all = habitStore.getAllHabitEntries(habitId: habit.id)
        return all.filter { ($0.date >= yearStart) && ($0.date < yearEnd) }
    }
    private var completedYTD: Int { yearEntries.filter { $0.isCompleted }.count }
    private var totalDaysYTD: Int {
        let today = min(Date(), yearEnd)
        let s = calendar.startOfDay(for: yearStart)
        let e = calendar.startOfDay(for: today)
        return (calendar.dateComponents([.day], from: s, to: e).day ?? 0) + 1
    }
    private var percentYTD: Int { guard totalDaysYTD > 0 else { return 0 }; return Int(round((Double(completedYTD) / Double(totalDaysYTD)) * 100.0)) }
    private var longestStreakYTD: Int {
        let sorted = yearEntries.sorted { $0.date < $1.date }
        var best = 0, current = 0
        var prevDay: Date? = nil
        for entry in sorted where entry.isCompleted {
            let day = calendar.startOfDay(for: entry.date)
            if let prev = prevDay, let nextPrev = calendar.date(byAdding: .day, value: 1, to: prev), calendar.isDate(day, inSameDayAs: nextPrev) {
                current += 1
            } else { current = 1 }
            prevDay = day
            best = max(best, current)
        }
        return best
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header (matches screenshot layout)
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Text(yearString())
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.blue)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(completedYTD) of \(totalDaysYTD) days • \(percentYTD)%")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .semibold))
                    Text("\(longestStreakYTD) days: longest streak")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                    Text("evoday.com")
                        .foregroundColor(.white)
                        .font(.system(size: 12))
                }
            }

            // 3-column grid of months
            let cols = Array(repeating: GridItem(.flexible(), spacing: 18), count: 3)
            LazyVGrid(columns: cols, alignment: .leading, spacing: 18) {
                ForEach(months, id: \.self) { month in
                    let data = habitStore.getHabitEntriesForMonth(habitId: habit.id, date: month)
                    let hasAny = data.contains { $0.isCompleted }
                    VStack(alignment: .leading, spacing: 8) {
                        Text(monthName(month))
                            .font(.subheadline)
                            .foregroundColor(hasAny ? .white : .gray)
                        MiniMonthGrid(month: month, monthlyData: data, color: habit.color)
                    }
                }
            }
        }
        .padding(16)
        .background(Color("grayblack"))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.2), lineWidth: 0.5))
        .cornerRadius(16)
    }

    private func monthName(_ date: Date) -> String { let f = DateFormatter(); f.dateFormat = "MMM"; return f.string(from: date) }
    private func yearString() -> String { let y = calendar.component(.year, from: Date()); return String(y) }

    // Mini month grid without weekday headers, compact squares
    private struct MiniMonthGrid: View {
        let month: Date
        let monthlyData: [DateProgress]
        let color: Color
        private let calendar = Calendar.current
        private var columns: [GridItem] { Array(repeating: GridItem(.fixed(12), spacing: 3, alignment: .center), count: 7) }
        private var leadingBlanks: Int {
            let startOfMonth = calendar.dateInterval(of: .month, for: month)?.start ?? month
            let weekdayOfStart = calendar.component(.weekday, from: startOfMonth)
            return (weekdayOfStart - calendar.firstWeekday + 7) % 7
        }
        private var daysInMonth: Int { calendar.range(of: .day, in: .month, for: month)?.count ?? 30 }
        private var completedSet: Set<Date> {
            let cal = calendar
            return Set(monthlyData.filter { $0.isCompleted }.map { cal.startOfDay(for: $0.date) })
        }
        var body: some View {
            LazyVGrid(columns: columns, alignment: .center, spacing: 3) {
                // Leading blanks
                ForEach(0..<leadingBlanks, id: \.self) { _ in
                    Color.clear.frame(width: 12, height: 12)
                }
                // Actual days
                ForEach(1...daysInMonth, id: \.self) { day in
                    let startOfMonth = calendar.dateInterval(of: .month, for: month)?.start ?? month
                    let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) ?? startOfMonth
                    let isCompleted = completedSet.contains(calendar.startOfDay(for: date))
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(isCompleted ? color : Color.gray.opacity(0.25))
                        .frame(width: 12, height: 12)
                        .overlay(RoundedRectangle(cornerRadius: 3, style: .continuous).stroke(Color.gray.opacity(0.25), lineWidth: 0.3))
                }
            }
        }
    }
}
