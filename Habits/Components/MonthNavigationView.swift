import SwiftUI

struct MonthNavigationView: View {
    @Binding var currentMonth: Date
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    var body: some View {
        // Deprecated per new design: keep printable month but without arrows
        HStack {
            Spacer()
            Text(monthFormatter.string(from: currentMonth))
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}
