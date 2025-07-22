import SwiftUI

struct AddHabitView: View {
    @EnvironmentObject var habitStore: HabitStore
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool
    
    @State private var habitName = ""
    @State private var selectedEmoji = "😊"
    @State private var selectedColorName = "blue"
    @State private var dailyGoal = 1
    @State private var selectedType: HabitType = .tracking
    
    let availableEmojis = ["💧", "😴", "📚", "🚶", "🏃", "🧘", "🍎", "💪", "🎯", "⭐", "🌱", "🎨", "💊", "🛏️", "📱", "🧹"]
    let availableColors: [(name: String, color: Color)] = [
        ("blue", .blue), ("green", .green), ("purple", .purple), ("orange", .orange),
        ("pink", .pink), ("red", .red), ("yellow", .yellow), ("mint", .mint)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Habit Type Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Habit Type")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 12) {
                            ForEach(HabitType.allCases, id: \.self) { type in
                                HabitTypeCard(
                                    type: type,
                                    isSelected: selectedType == type,
                                    onSelect: { selectedType = type }
                                )
                            }
                        }
                    }
                    
                    // Habit Name
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Habit Name")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextField("Enter habit name", text: $habitName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($isTextFieldFocused)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    isTextFieldFocused = true
                                }
                            }
                    }
                    
                    // Emoji Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Choose Emoji")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                            ForEach(availableEmojis, id: \.self) { emoji in
                                Text(emoji)
                                    .font(.title2)
                                    .frame(width: 35, height: 35)
                                    .background(selectedEmoji == emoji ? Color.gray.opacity(0.3) : Color.clear)
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        selectedEmoji = emoji
                                    }
                            }
                        }
                    }
                    
                
                    
                    // Daily Goal (only for tracking habits)
                    if selectedType == .tracking {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Daily Goal")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack {
                                Button(action: {
                                    if dailyGoal > 1 {
                                        dailyGoal -= 1
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.gray)
                                        .font(.title2)
                                }
                                
                                Spacer()
                                
                                Text("\(dailyGoal)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: {
                                    if dailyGoal < 100 {
                                        dailyGoal += 1
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    // Color Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Choose Color")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                            ForEach(availableColors, id: \.name) { colorInfo in
                                Circle()
                                    .fill(colorInfo.color)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: selectedColorName == colorInfo.name ? 3 : 0)
                                    )
                                    .onTapGesture {
                                        selectedColorName = colorInfo.name
                                    }
                            }
                        }
                    }
                    Spacer(minLength: 60)
                }
                .padding(20)
            }
            .background(Color("backgroundblack"))
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let newHabit = Habit(
                            emoji: selectedEmoji,
                            name: habitName,
                            colorName: selectedColorName,
                            dailyGoal: selectedType == .tracking ? dailyGoal : 1,
                            type: selectedType
                        )
                        habitStore.addHabit(newHabit)
                        dismiss()
                    }
                    .foregroundColor(habitName.isEmpty ? .gray : .green)
                    .disabled(habitName.isEmpty)
                }
            }
        }
    }
}

struct HabitTypeCard: View {
    let type: HabitType
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(type.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .green : .gray)
            }
            
            Text(type.example)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .background(isSelected ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.green : Color.gray.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
        .onTapGesture {
            onSelect()
        }
    }
}
