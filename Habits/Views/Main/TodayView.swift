import SwiftUI

struct TodayView: View {
    @EnvironmentObject var habitStore: HabitStore
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView().environmentObject(habitStore)
            
            ScrollView {
                VStack(spacing: 24) {
                     AdvancedWeeklyDatePicker(selectedDate: $habitStore.selectedDate, habitStore: habitStore)
                    DailyCheckInSection()
                }
                .padding(.horizontal, 20)
            }
            .scrollIndicators(.hidden)
        }
    }
}

