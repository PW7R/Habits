import SwiftUI

struct GitHubContributionGrid: View {
    let monthlyData: [DateProgress]
    let color: Color
    let currentMonth: Date
    
    // Fixed width columns to get uniform small rounded squares similar to GitHub
    private let columns = Array(repeating: GridItem(.fixed(14), spacing: 3, alignment: .center), count: 7)
    private let calendar = Calendar.current
    
    private var gridData: [GridDay] {
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        let weekdayOfStart = calendar.component(.weekday, from: startOfMonth)
        // Number of leading blanks based on user's locale firstWeekday
        let leading = (weekdayOfStart - calendar.firstWeekday + 7) % 7
        
        var days: [GridDay] = []
        
        // Add empty days for proper alignment
        for _ in 0..<leading {
            days.append(GridDay(date: nil, progress: nil))
        }
        
        // Add actual days
        for dayData in monthlyData {
            days.append(GridDay(date: dayData.date, progress: dayData))
        }
        
        return days
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Weekday headers localized and adjusted to calendar.firstWeekday
            HStack {
                ForEach(weekdaySymbols(), id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Grid
            LazyVGrid(columns: columns, alignment: .center, spacing: 3) {
                ForEach(gridData.indices, id: \.self) { index in
                    let day = gridData[index]
                    ContributionDayView(day: day, baseColor: color)
                }
            }
        }
    }

    private func weekdaySymbols() -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        let symbols = formatter.shortWeekdaySymbols
        let first = calendar.firstWeekday - 1 // convert to 0-based
        return Array(symbols![first...]) + Array(symbols![..<first])
    }
}

struct GridDay {
    let date: Date?
    let progress: DateProgress?
}

struct ContributionDayView: View {
    let day: GridDay
    let baseColor: Color
    
    private var isCompleted: Bool {
        guard let progress = day.progress else { return false }
        return progress.isCompleted
    }
    
    private var fillColor: Color {
        if day.date == nil { return Color.clear }
        
        return isCompleted ? baseColor : Color.gray.opacity(0.3)
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(fillColor)
            .frame(width: 14, height: 14, alignment: .center)
            .overlay(
                day.date != nil ?
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .stroke(Color.gray.opacity(0.25), lineWidth: 0.5) : nil
            )
    }
}
