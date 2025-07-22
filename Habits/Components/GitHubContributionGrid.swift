import SwiftUI

struct GitHubContributionGrid: View {
    let monthlyData: [DateProgress]
    let color: Color
    let currentMonth: Date
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 7)
    private let calendar = Calendar.current
    
    private var gridData: [GridDay] {
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        
        var days: [GridDay] = []
        
        // Add empty days for proper alignment
        for _ in 1..<firstWeekday {
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
            // Weekday headers with abbreviated names
            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Grid
            LazyVGrid(columns: columns, spacing: 3) {
                ForEach(gridData.indices, id: \.self) { index in
                    let day = gridData[index]
                    
                    ContributionDayView(
                        day: day,
                        baseColor: color
                    )
                }
            }
        }
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
        Rectangle()
            .fill(fillColor)
            .frame(alignment: .center)
            .cornerRadius(2)
            .overlay(
                day.date != nil ?
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 0.5) : nil
            )
    }
}
