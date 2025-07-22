import Foundation
import SwiftUI
import CoreData

class HabitStore: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var selectedDate: Date = Date()
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    init() {
        container = NSPersistentContainer(name: "HabitsDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        context = container.viewContext
        loadHabits()
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
        
        saveContext()
        loadHabits()
    }
    
    func updateHabitProgress(habitId: UUID, newProgress: Int) {
        // Update the habit's current progress
        if let habitEntity = fetchHabitEntity(by: habitId) {
            habitEntity.currentProgress = Int32(newProgress)
            
            // Create or update daily progress entry for the selected date
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
        let request: NSFetchRequest<DailyProgressEntity> = DailyProgressEntity.fetchRequest()
        request.predicate = NSPredicate(format: "habitId == %@ AND date == %@", 
                                      habitId as CVarArg, date as CVarArg)
        
        if let existing = try? context.fetch(request).first {
            return existing
        } else {
            let newProgress = DailyProgressEntity(context: context)
            newProgress.id = UUID()
            newProgress.habitId = habitId
            newProgress.date = date
            return newProgress
        }
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
        request.sortDescriptors = [NSSortDescriptor(keyPath: \HabitEntity.createdAt, ascending: true)]
        
        do {
            let habitEntities = try context.fetch(request)
            habits = habitEntities.map { entity in
                var habit = Habit(from: entity)
                
                // Load the completion status for the selected date
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
        let request: NSFetchRequest<DailyProgressEntity> = DailyProgressEntity.fetchRequest()
        request.predicate = NSPredicate(format: "habitId == %@ AND date == %@", 
                                      habitId as CVarArg, date as CVarArg)
        return try? context.fetch(request).first
    }
    
    // MARK: - Computed Properties
    var trackingHabits: [Habit] {
        habits.filter { $0.type == .tracking }
    }
    
    var oneTimeHabits: [Habit] {
        habits.filter { $0.type == .oneTime }
    }
    
    var completedHabitsCount: Int {
        habits.filter { $0.isCompleted }.count
    }
    
    var totalHabitsCount: Int {
        habits.count
    }
    
    // MARK: - Date Navigation
    func updateSelectedDate(_ newDate: Date) {
        selectedDate = newDate
        loadHabits() // Reload habits for the new date
    }
    
    // MARK: - Statistics
    func getHabitEntriesForMonth(habitId: UUID, date: Date) -> [DateProgress] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: date)?.start ?? date
        let endOfMonth = calendar.dateInterval(of: .month, for: date)?.end ?? date
        
        let request: NSFetchRequest<DailyProgressEntity> = DailyProgressEntity.fetchRequest()
        request.predicate = NSPredicate(format: "habitId == %@ AND date >= %@ AND date < %@", 
                                      habitId as CVarArg, startOfMonth as CVarArg, endOfMonth as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DailyProgressEntity.date, ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            return entities.map { entity in
                DateProgress(
                    date: entity.date ?? Date(),
                    progress: Int(entity.progress),
                    goal: 1, // Will be updated with actual goal
                    isCompleted: entity.isCompleted
                )
            }
        } catch {
            print("Error fetching daily progress: \(error)")
            return []
        }
    }
} 