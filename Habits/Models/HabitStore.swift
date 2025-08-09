import Foundation
import SwiftUI
import CoreData

class HabitStore: ObservableObject {
    @Published var habits: [Habit] = []
    // Always keep selectedDate normalized to start-of-day to avoid timezone/DST issues
    @Published var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    // Month displayed in header. Updates only when user selects day 1 explicitly.
    @Published var displayedMonthDate: Date = Calendar.current.startOfDay(for: Date())
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    init() {
        container = NSPersistentContainer(name: "HabitsDataModel")
        // Enable lightweight migration
        if let description = container.persistentStoreDescriptions.first {
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
        }
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        context = container.viewContext
        loadHabits()
        // Initialize displayed month to current month start
        displayedMonthDate = selectedDate
    }
    
    // MARK: - Habit Management
    func addHabit(_ habit: Habit) {
        let habitEntity = HabitEntity(context: context)
        habitEntity.id = habit.id
        habitEntity.emoji = habit.emoji
        habitEntity.name = habit.name
        habitEntity.colorName = habit.colorName
        habitEntity.dailyGoal = Int32(habit.dailyGoal)
        habitEntity.type = habit.type.rawValue
        habitEntity.createdAt = Date()
        // Persist weekly schedule and default sort order at end.
        let weekdaysString = habit.activeWeekdays.sorted().map(String.init).joined(separator: ",")
        habitEntity.activeWeekdays = weekdaysString
        habitEntity.sortIndex = nextSortIndex()
        
        saveContext()
        loadHabits()
    }
    
    func updateHabitProgress(habitId: UUID, newProgress: Int) {
        // Update the habit's current progress
        if let habitEntity = fetchHabitEntity(by: habitId) {
            habitEntity.currentProgress = Int32(newProgress)
            
            // Create or update daily progress entry for the selected date.
            let dailyProgress = fetchOrCreateDailyProgress(for: habitId, date: selectedDate)
            dailyProgress.progress = Int32(newProgress)
            dailyProgress.isCompleted = newProgress >= habitEntity.dailyGoal
            
            saveContext()
            loadHabits()
        }
    }
    
    func toggleOneTimeHabit(habitId: UUID) {
        if let habitEntity = fetchHabitEntity(by: habitId) {
            habitEntity.isChecked.toggle()
            
            // Create or update daily progress entry for the selected date
            let dailyProgress = fetchOrCreateDailyProgress(for: habitId, date: selectedDate)
            dailyProgress.isCompleted = habitEntity.isChecked
            
            saveContext()
            loadHabits()
        }
    }
    
    // MARK: - Core Data Helpers
    private func fetchHabitEntity(by id: UUID) -> HabitEntity? {
        let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try? context.fetch(request).first
    }
    
    private func fetchOrCreateDailyProgress(for habitId: UUID, date: Date) -> DailyProgressEntity {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay

        let request: NSFetchRequest<DailyProgressEntity> = DailyProgressEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "habitId == %@ AND date >= %@ AND date < %@",
            habitId as CVarArg, startOfDay as CVarArg, endOfDay as CVarArg
        )

        if let existing = try? context.fetch(request).first {
            return existing
        } else {
            let newProgress = DailyProgressEntity(context: context)
            newProgress.id = UUID()
            newProgress.habitId = habitId
            // Normalize persisted date to start-of-day
            newProgress.date = startOfDay
            return newProgress
        }
    }
    
    private func nextSortIndex() -> Int32 {
        let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \HabitEntity.sortIndex, ascending: false)]
        request.fetchLimit = 1
        if let maxEntity = try? context.fetch(request).first {
            return maxEntity.sortIndex + 1
        }
        return 0
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    private func loadHabits() {
        let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
        // Sort by custom order first, fallback to createdAt
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \HabitEntity.sortIndex, ascending: true),
            NSSortDescriptor(keyPath: \HabitEntity.createdAt, ascending: true)
        ]
        
        do {
            let habitEntities = try context.fetch(request)
            habits = habitEntities.map { entity in
                var habit = Habit(from: entity)
                
                // Load the completion status for the selected date (match by day range)
                let dailyProgress = fetchDailyProgress(for: entity.id ?? UUID(), date: selectedDate)
                if let progress = dailyProgress {
                    habit.currentProgress = Int(progress.progress)
                    habit.isChecked = progress.isCompleted
                } else {
                    // Reset to 0 if no progress for this date
                    habit.currentProgress = 0
                    habit.isChecked = false
                }
                
                return habit
            }
        } catch {
            print("Error loading habits: \(error)")
        }
    }
    
    private func fetchDailyProgress(for habitId: UUID, date: Date) -> DailyProgressEntity? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay

        let request: NSFetchRequest<DailyProgressEntity> = DailyProgressEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "habitId == %@ AND date >= %@ AND date < %@",
            habitId as CVarArg, startOfDay as CVarArg, endOfDay as CVarArg
        )
        return try? context.fetch(request).first
    }
    
    // MARK: - Computed Properties
    private var selectedWeekday: Int { Calendar.current.component(.weekday, from: selectedDate) }
    
    var visibleHabits: [Habit] {
        habits
            .filter { $0.activeWeekdays.contains(selectedWeekday) }
            .sorted { $0.sortIndex < $1.sortIndex }
    }
    
    var trackingHabits: [Habit] { visibleHabits.filter { $0.type == .tracking } }
    
    var oneTimeHabits: [Habit] { visibleHabits.filter { $0.type == .oneTime } }
    
    var completedHabitsCount: Int { visibleHabits.filter { $0.isCompleted }.count }
    
    var totalHabitsCount: Int { visibleHabits.count }
    
    // For Settings reorder UI
    var habitsSortedForSettings: [Habit] {
        habits.sorted { $0.sortIndex < $1.sortIndex }
    }
    
    // MARK: - Date Navigation
    func updateSelectedDate(_ newDate: Date) {
		// Normalize to start-of-day to avoid off-by-one issues
		let normalized = Calendar.current.startOfDay(for: newDate)
		selectedDate = normalized
		loadHabits() // Reload habits for the new date
		// Always keep the displayed month in sync with the selected date's month
		displayedMonthDate = normalized
    }
    
    // MARK: - Reordering
    func moveHabits(fromOffsets: IndexSet, toOffset: Int) {
        var ordered = habitsSortedForSettings
        ordered.move(fromOffsets: fromOffsets, toOffset: toOffset)
        for (idx, habit) in ordered.enumerated() {
            if let entity = fetchHabitEntity(by: habit.id) {
                entity.sortIndex = Int32(idx)
            }
        }
        saveContext()
        loadHabits()
    }
    
    // MARK: - Statistics
     func getHabitEntriesForMonth(habitId: UUID, date: Date) -> [DateProgress] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: date)?.start ?? date
        let endOfMonth = calendar.dateInterval(of: .month, for: date)?.end ?? date

        let request: NSFetchRequest<DailyProgressEntity> = DailyProgressEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "habitId == %@ AND date >= %@ AND date < %@",
            habitId as CVarArg, startOfMonth as CVarArg, endOfMonth as CVarArg
        )
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DailyProgressEntity.date, ascending: true)]

        do {
            let entities = try context.fetch(request)
            let dailyGoal = Int(fetchHabitEntity(by: habitId)?.dailyGoal ?? 1)
            return entities.map { entity in
                DateProgress(
                    date: entity.date ?? Date(),
                    progress: Int(entity.progress),
                    goal: dailyGoal,
                    isCompleted: entity.isCompleted
                )
            }
        } catch {
            print("Error fetching daily progress: \(error)")
            return []
        }
    }

    // MARK: - Extended statistics helpers
     func getAllHabitEntries(habitId: UUID) -> [DateProgress] {
        let request: NSFetchRequest<DailyProgressEntity> = DailyProgressEntity.fetchRequest()
        request.predicate = NSPredicate(format: "habitId == %@", habitId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DailyProgressEntity.date, ascending: true)]

        do {
            let entities = try context.fetch(request)
            let dailyGoal = Int(fetchHabitEntity(by: habitId)?.dailyGoal ?? 1)
            return entities.map { entity in
                DateProgress(
                    date: entity.date ?? Date(),
                    progress: Int(entity.progress),
                    goal: dailyGoal,
                    isCompleted: entity.isCompleted
                )
            }
        } catch {
            print("Error fetching all daily progress: \(error)")
            return []
        }
    }

     func getEntriesForLast365Days(habitId: UUID, from referenceDate: Date = Date()) -> [DateProgress] {
        let calendar = Calendar.current
        let end = calendar.startOfDay(for: referenceDate)
        let start = calendar.date(byAdding: .day, value: -364, to: end) ?? end

        let request: NSFetchRequest<DailyProgressEntity> = DailyProgressEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "habitId == %@ AND date >= %@ AND date <= %@",
            habitId as CVarArg, start as CVarArg, end as CVarArg
        )
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DailyProgressEntity.date, ascending: true)]

        do {
            let entities = try context.fetch(request)
            let dailyGoal = Int(fetchHabitEntity(by: habitId)?.dailyGoal ?? 1)
            return entities.map { entity in
                DateProgress(
                    date: entity.date ?? Date(),
                    progress: Int(entity.progress),
                    goal: dailyGoal,
                    isCompleted: entity.isCompleted
                )
            }
        } catch {
            print("Error fetching last 365 days entries: \(error)")
            return []
        }
    }
}
 
