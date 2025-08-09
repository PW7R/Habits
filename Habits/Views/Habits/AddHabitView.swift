import SwiftUI
import UIKit

struct AddHabitView: View {
    @EnvironmentObject var habitStore: HabitStore
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool
    
    // Core inputs
    @State private var habitName = ""
    @State private var selectedEmoji = "😀"
    @State private var selectedColor: Color = Color("Lime")
    
    // Scheduling and behavior
    @State private var repeatsPerDay: Int = 1
    @State private var selectedWeekdays: Set<Int> = [1,2,3,4,5,6,7] // 1=Sun ... 7=Sat
    @State private var remindersEnabled: Bool = false
    @State private var reminderTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    
    // Sheet controls
    @State private var showEmojiPicker: Bool = false
    @State private var showColorPicker: Bool = false
    @State private var showFrequencySheet: Bool = false
    @State private var showRepeatsSheet: Bool = false
    @State private var showRemindersSheet: Bool = false
    
    // Limited emoji set as a fallback to system emoji keyboard unavailability
    private let availableEmojis = ["😀","😅","😊","😍","🤩","😎","😴","📚","🚶","🏃","🧘","🍎","💪","🎯","⭐","🌱","🎨","💊","🛏️"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {
                        // Top: Icon and Colour capsules
                        HStack(spacing: 12) {
                            Button(action: { 
                                // Defocus main text input to avoid keyboard reappearing
                                isTextFieldFocused = false
                                showEmojiPicker = true 
                            }) {
                                HStack(spacing: 8) {
                                    Text(selectedEmoji)
                                        .font(.system(size: 18))
                                    Text("Icon")
                                        .foregroundColor(.white)
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .frame(minWidth: 130, minHeight: 40)
                                .background(Color("grayblack"))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                                )
                            }
                            
                            Button(action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { showColorPicker.toggle() } }) {
                                HStack(spacing: 8) {
                                    Circle().fill(selectedColor).frame(width: 14, height: 14)
                                    Text("Color")
                                        .foregroundColor(.white)
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .frame(minWidth: 130, minHeight: 40)
                                .background(Color("grayblack"))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                                )
                            }
                            Spacer()
                        }
                        
                        if showColorPicker {
                            ColorSwatchGrid(showColorPicker: $showColorPicker, selectedColor: $selectedColor)
                        }

                        
                        // Habit name inline editable title
                        ZStack(alignment: .leading) {
                            if habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text("Habit's name")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white.opacity(0.35))
                            }
                            TextField("", text: $habitName)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .focused($isTextFieldFocused)
                                .disableAutocorrection(true)
                                .textInputAutocapitalization(.words)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { isTextFieldFocused = true }
                                }
                        }
                        
                        // Options list
                        VStack(spacing: 10) {
                            OptionRow(title: "Frequency", value: frequencySummary) {
                                showFrequencySheet = true
                            }
                            OptionRow(title: "Repeats", value: repeatsSummary) { showRepeatsSheet = true }
                            OptionRow(title: "Reminders", value: remindersEnabled ? timeString(reminderTime) : "Off") { showRemindersSheet = true }
                        }
                        //.padding(.top, 8)
                        
                        Spacer(minLength: 80)
                    }
                    .padding(20)
                }
                .scrollDisabled(true)
                .scrollIndicators(.hidden)
                
                
                // Create button
                Button(action: createHabit) {
                    Text("Create new")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color("Lime"))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                }
                .disabled(habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1)
            }            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }.foregroundColor(.white)
                }

            }
            // MARK: Sheets
            .sheet(isPresented: $showEmojiPicker) {
                EmojiPickerSheet(selectedEmoji: $selectedEmoji, availableEmojis: availableEmojis)
                    .emojiBottomSheetStyle()
            }
            .sheet(isPresented: $showFrequencySheet) {
                FrequencyPickerSheet(selectedWeekdays: $selectedWeekdays)
                    .bottomSheetStyle()
            }
            .sheet(isPresented: $showRepeatsSheet) {
                RepeatsPickerSheet(repeatsPerDay: $repeatsPerDay)
                    .bottomSheetStyle()
            }
            .sheet(isPresented: $showRemindersSheet) {
                RemindersSheet(remindersEnabled: $remindersEnabled, reminderTime: $reminderTime)
                    .bottomSheetStyle()
            }
        }
        .onChange(of: showEmojiPicker) { isPresented in
            if !isPresented {
                // Re-focus name field after sheet finishes dismissing
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    isTextFieldFocused = true
                }
            }
        }
    }
}

// MARK: - Option Row
private struct OptionRow: View {
    let title: String
    let value: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text(value)
                    .foregroundColor(.white.opacity(0.9))
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(14)
            .background(Color("grayblack"))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
            )
        }
    }
}

// MARK: - Emoji Picker Sheet
private struct EmojiPickerSheet: View {
    @Binding var selectedEmoji: String
    let availableEmojis: [String]
    @State private var inputEmoji: String = ""
    @FocusState private var isEmojiFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    private func finish() {
        // Unfocus keyboard and dismiss the sheet in the same animation pass
        // to avoid multi-step bouncing.
        isEmojiFieldFocused = false
        DispatchQueue.main.async { dismiss() }
    }
    
    private var emojiInputField: some View {
        TextField("Tap to pick emoji", text: $inputEmoji)
            .keyboardType(.emoji)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .multilineTextAlignment(.center)
            .font(.system(size: 44))
            .focused($isEmojiFieldFocused)
            .submitLabel(.done)
            .onSubmit { finish() }
            .frame(height: 72)
            .padding(.horizontal, 12)
            .background(Color("grayblack"))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.gray.opacity(0.25), lineWidth: 1)
            )
            .onChange(of: inputEmoji) { newVal in
                if let last = newVal.last {
                    selectedEmoji = String(last)
                    inputEmoji = String(last)
                } else {
                    selectedEmoji = ""
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isEmojiFieldFocused = true
                }
            }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    emojiInputField
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                        ForEach(availableEmojis, id: \.self) { emoji in
                            Text(emoji)
                                .font(.title2)
                                .frame(width: 36, height: 36)
                                .background(selectedEmoji == emoji ? Color.gray.opacity(0.25) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .onTapGesture {
                                    selectedEmoji = emoji
                                    inputEmoji = emoji
                                }
                        }
                    }
                }
                .padding()
            }
            .scrollIndicators(.hidden)
            .background(Color("backgroundblack"))
            .navigationTitle("Emoji")
            .interactiveDismissDisabled(isEmojiFieldFocused)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { finish() }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Frequency Picker
private struct FrequencyPickerSheet: View {
    @Binding var selectedWeekdays: Set<Int> // 1..7, Sun..Sat
    private let days = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(1...7, id: \.self) { i in
                    Button(action: { toggle(i) }) {
                        HStack {
                            Text(days[i-1]).foregroundColor(.white)
                            Spacer()
                            if selectedWeekdays.contains(i) {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(Color("Lime"))
                            } else {
                                Image(systemName: "circle").foregroundColor(.gray)
                            }
                        }
                    }
                    .listRowBackground(Color("grayblack"))
                }
            }
            .background(Color("backgroundblack"))
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .navigationTitle("Frequency")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(.white)
                }
            }
        }
    }
    
    private func toggle(_ day: Int) { if selectedWeekdays.contains(day) { selectedWeekdays.remove(day) } else { selectedWeekdays.insert(day) } }
}

// MARK: - Repeats Picker Sheet
private struct RepeatsPickerSheet: View {
    @Binding var repeatsPerDay: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) { // ✨ edited (more spacing for cleaner look)
                
                // Quick picks
                ScrollView(.horizontal, showsIndicators: false) { // ✨ edited (scrollable pills)
                    HStack(spacing: 12) {
                        ForEach([1, 2, 3, 5, 10, 20], id: \.self) { value in
                            Text("\(value)") // ✨ edited (fixed interpolation)
                                .font(.system(size: 16, weight: .semibold)) // ✨ edited (bigger text)
                                .foregroundColor(repeatsPerDay == value ? .black : .white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 18)
                                .background(repeatsPerDay == value ? Color("Lime") : Color("grayblack"))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(Color.gray.opacity(0.25), lineWidth: 1)
                                )
                                .onTapGesture { repeatsPerDay = value }
                        }
                    }
                    .padding(.horizontal, 10) // ✨ edited
                }
                
                // Summary card
                Text(repeatsPerDay == 1 ? "1 time per day" : "\(repeatsPerDay) times per day") // ✨ edited
                    .font(.system(size: 16, weight: .medium)) // ✨ edited
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(Color("grayblack"))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous)) // ✨ edited
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    )
                
                // Wheel picker inside card
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous) // ✨ edited
                        .fill(Color("grayblack"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                        )
                    Picker("Repeats per day", selection: $repeatsPerDay) {
                        ForEach(1...100, id: \.self) { value in
                            Text("\(value)") // ✨ edited (fixed interpolation)
                                .foregroundColor(.white) // ✨ edited
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                }
                .frame(height: 220) // ✨ edited (slightly taller)
                
                Spacer()
            }
            .padding()
            .background(Color("backgroundblack"))
            .navigationTitle("Repeats")
            .navigationBarTitleDisplayMode(.inline) // ✨ edited (inline title for consistency)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(.white)
                }
            }
        }
    }
}


// MARK: - Reminders Sheet
private struct RemindersSheet: View {
    @Binding var remindersEnabled: Bool
    @Binding var reminderTime: Date
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
            Form {
                Toggle("Enable reminder", isOn: $remindersEnabled)
                DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    .disabled(!remindersEnabled)
            }
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .background(Color("backgroundblack"))
            .tint(Color("Lime"))
            .navigationTitle("Reminders")
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { dismiss() }.foregroundColor(.white) } }
        }
    }
}

// MARK: - View helpers
private extension AddHabitView {
    var frequencySummary: String {
        if selectedWeekdays.count == 7 { return "Every day" }
        if selectedWeekdays.isEmpty { return "None" }
        return "\(selectedWeekdays.count) days/week"
    }
    
    var repeatsSummary: String { repeatsPerDay == 1 ? "1 time per day" : "\(repeatsPerDay) times per day" }
    
    func timeString(_ date: Date) -> String {
        let f = DateFormatter(); f.timeStyle = .short; return f.string(from: date)
    }
    
    
    func createHabit() {
        let colorHex = selectedColor.toHex() ?? "#7ED321" // fallback lime
        let type: HabitType = repeatsPerDay == 1 ? .oneTime : .tracking
        let newHabit = Habit(
            emoji: selectedEmoji,
            name: habitName,
            colorName: colorHex,
            dailyGoal: repeatsPerDay,
            type: type,
            activeWeekdays: selectedWeekdays
        )
        habitStore.addHabit(newHabit)
        if remindersEnabled {
            NotificationManager.shared.requestAuthorizationIfNeeded()
            NotificationManager.shared.scheduleWeeklyNotifications(habit: newHabit, weekdays: Array(selectedWeekdays), time: reminderTime)
        }
        dismiss()
    }
}

// MARK: - Inline Colour Swatch Grid
private struct ColorSwatchGrid: View {
    @Binding var showColorPicker: Bool
    @Binding var selectedColor: Color
    private let swatches: [Color] = [
        Color("Lime"),Color("Lavander"),Color("RedLove"),
        .red, .orange, .yellow,
        .green, .mint, .teal,
        .blue, .purple, .pink
    ]
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 10), spacing: 10) {
            ForEach(0..<swatches.count, id: \.self) { idx in
                let color = swatches[idx]
                Circle()
                    .fill(color)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle().stroke(Color.white.opacity(colorsEqual(selectedColor, color) ? 1 : 0), lineWidth: 2)
                    )
                    .onTapGesture {
                        selectedColor = color
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showColorPicker = false
                        }
                    }
            }
        }
        .padding(.vertical, 6)
    }
    private func colorsEqual(_ a: Color, _ b: Color) -> Bool {
        let ua = UIColor(a)
        let ub = UIColor(b)
        var ar: CGFloat = 0, ag: CGFloat = 0, ab: CGFloat = 0, aa: CGFloat = 0
        var br: CGFloat = 0, bg: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 0
        if ua.getRed(&ar, green: &ag, blue: &ab, alpha: &aa) && ub.getRed(&br, green: &bg, blue: &bb, alpha: &ba) {
            return abs(ar - br) < 0.001 && abs(ag - bg) < 0.001 && abs(ab - bb) < 0.001 && abs(aa - ba) < 0.001
        }
        return false
    }
}

// MARK: - Emoji keyboard support
extension UIKeyboardType {
    // Non-optional emoji keyboard type with safe fallback to .default
    static var emoji: UIKeyboardType {
        UIKeyboardType(rawValue: 124) ?? .default
    }
}
