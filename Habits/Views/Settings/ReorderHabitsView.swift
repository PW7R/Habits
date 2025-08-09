import SwiftUI

struct ReorderHabitsView: View {
    @EnvironmentObject var habitStore: HabitStore
    
    var body: some View {
        ZStack {
            Color("backgroundblack").ignoresSafeArea()
            
            List {
                Section(header: Text("Reorder Habits").foregroundColor(.white)) {
                    ForEach(habitStore.habitsSortedForSettings) { habit in
                        HStack(spacing: 12) {
                            Text(habit.emoji)
                            Text(habit.name)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .listRowBackground(Color("grayblack"))
                    }
                    .onMove(perform: habitStore.moveHabits)
                }
            }
            .environment(\.defaultMinListHeaderHeight, 0)
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .listStyle(.insetGrouped)
            .tint(Color("Lime"))
        }
        .navigationTitle("Reorder")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) { EditButton() }
        }
    }
}
