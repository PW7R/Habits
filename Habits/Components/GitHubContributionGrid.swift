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
    let squareSize: CGFloat

    init(day: GridDay, baseColor: Color, squareSize: CGFloat = 14) {
        self.day = day
        self.baseColor = baseColor
        self.squareSize = squareSize
    }

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
            .frame(width: squareSize, height: squareSize, alignment: .center)
            .overlay(
                day.date != nil ?
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .stroke(Color.gray.opacity(0.25), lineWidth: 0.5) : nil
            )
    }
}

// MARK: - Weekly Grid (7 squares)
struct WeeklyContributionGrid: View {
	let monthlyData: [DateProgress]
	let color: Color
	
	private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.fixed(20), spacing: 6, alignment: .center), count: 7)
	
	private var weekDays: [GridDay] {
		let today = Date()
		let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
		// Align the start with the user's firstWeekday
		let startWeekday = calendar.component(.weekday, from: startOfWeek)
		let adjust = (startWeekday - calendar.firstWeekday + 7) % 7
		let normalizedStart = calendar.date(byAdding: .day, value: -adjust, to: startOfWeek) ?? startOfWeek
		return (0..<7).map { offset in
			let day = calendar.date(byAdding: .day, value: offset, to: normalizedStart) ?? normalizedStart
			let match = monthlyData.first { calendar.isDate($0.date, inSameDayAs: day) }
			return GridDay(date: day, progress: match)
		}
	}
	
	var body: some View {
		LazyVGrid(columns: columns, alignment: .center, spacing: 6) {
			ForEach(weekDays.indices, id: \.self) { index in
				let day = weekDays[index]
				VStack(spacing: 6) {
					Text(weekdaySymbol(for: day.date ?? Date()))
						.font(.caption2)
						.foregroundColor(.gray)
						.lineLimit(1)
						.minimumScaleFactor(0.8)
					ContributionDayView(day: day, baseColor: color, squareSize: 20)
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

	private func weekdaySymbol(for date: Date) -> String {
		let formatter = DateFormatter()
		formatter.locale = Locale.current
		formatter.setLocalizedDateFormatFromTemplate("EEEEE") // narrow day symbol (1 letter)
		return formatter.string(from: date)
	}
}
