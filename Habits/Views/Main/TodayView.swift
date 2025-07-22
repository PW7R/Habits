import SwiftUI

struct TodayView: View {
    @EnvironmentObject var habitStore: HabitStore
    @State private var showingAddHabit = false
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            
            ScrollView {
                VStack(spacing: 24) {
                    AdvancedWeeklyDatePicker(selectedDate: $habitStore.selectedDate, habitStore: habitStore)
                    DailyCheckInSection()
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
        }
        .overlay(
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showingAddHabit = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                            .font(.title)
                            .background(Color("backgroundblack"))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 10)
                }
                Spacer()
            }
        )
        .sheet(isPresented: $showingAddHabit) {
            AddHabitView().environmentObject(habitStore)
        }
    }
}
