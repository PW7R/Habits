import SwiftUI

struct StatsView: View {
    @EnvironmentObject var habitStore: HabitStore
    @State private var currentMonth = Date()
    @State private var selectedHabitForSheet: Habit? = nil
    
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
            
            // Remove MonthNavigationView per request
            
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(habitStore.habits) { habit in
                        HabitStatsCard(habit: habit, currentMonth: currentMonth)
                            .environmentObject(habitStore)
                            .onTapGesture { selectedHabitForSheet = habit }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
        .sheet(item: $selectedHabitForSheet) { habit in
            HabitStatsSheet(habit: habit)
                .environmentObject(habitStore)
        }
    }
}

// MARK: - Habit Stats Sheet and supporting views inline to avoid Xcode target issues
struct HabitStatsSheet: View, Identifiable {
    let id = UUID()
    let habit: Habit
    @EnvironmentObject var habitStore: HabitStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingEdit = false

    private var allEntries: [DateProgress] { habitStore.getAllHabitEntries(habitId: habit.id) }
    private var last365Entries: [DateProgress] { habitStore.getEntriesForLast365Days(habitId: habit.id) }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    AllTimeStatsCard(habit: habit, entries: allEntries)
                    Last365DaysCard(entries: last365Entries, color: habit.color)
                    YearOverviewCard(habit: habit)
                }
                .padding(20)
                .background(Color("backgroundblack").ignoresSafeArea())
            }
            .navigationTitle(habit.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") { showingEdit = true }
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showingEdit) { AddHabitView().environmentObject(habitStore) }
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
    private let columns = Array(repeating: GridItem(.fixed(12), spacing: 3, alignment: .center), count: 7)
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
    private var months: [Date] {
        let yearStart = calendar.date(from: calendar.dateComponents([.year], from: Date())) ?? Date()
        return (0..<12).compactMap { calendar.date(byAdding: .month, value: $0, to: yearStart) }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Year").font(.headline).foregroundColor(.white)
            LazyVStack(spacing: 16) {
                ForEach(months, id: \.self) { month in
                    let data = habitStore.getHabitEntriesForMonth(habitId: habit.id, date: month)
                    let completed = data.filter { $0.isCompleted }.count
                    let total = data.count
                    VStack(alignment: .leading, spacing: 8) {
                        HStack { Text(monthName(month)).font(.subheadline).foregroundColor(.white); Spacer(); Text("\(completed) of \(total) days").font(.caption).foregroundColor(.gray) }
                        GitHubContributionGrid(monthlyData: data, color: habit.color, currentMonth: month)
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
}
