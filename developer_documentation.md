# Habits App - Developer Documentation

## 1. Project Overview

**Habits** is a native iOS application built with **SwiftUI** designed to help users track and build daily habits. It features a sleek, dark-themed UI, interactive charts, and a focus on simplicity and visual feedback.

### Key Technologies
-   **UI Framework**: SwiftUI
-   **Persistence**: Core Data
-   **Notifications**: UserNotifications (Local Notifications)
-   **Minimum iOS Version**: iOS 16.0+ (Inferred from usage of `NavigationStack` and `Charts` or similar modern APIs).

## 2. Architecture

The app follows a **MVVM (Model-View-ViewModel)** pattern, though it leans heavily on a centralized store approach for simplicity.

-   **Model**: `Habit` (Domain Model), `HabitEntity` (Core Data Entity).
-   **View**: SwiftUI Views (e.g., `TodayView`, `StatsView`).
-   **ViewModel / Store**: `HabitStore` acts as the central `ObservableObject` that manages state, business logic, and database interactions. It is injected into the view hierarchy via `.environmentObject`.

### Data Flow
1.  **User Action**: User interacts with a View (e.g., taps a habit to increment progress).
2.  **Store Update**: The View calls a method on `HabitStore` (e.g., `updateHabitProgress`).
3.  **Persistence**: `HabitStore` updates the Core Data context and saves changes.
4.  **UI Refresh**: `@Published` properties in `HabitStore` trigger a UI re-render.

## 3. Directory Structure

```
Habits/
├── App/
│   └── HabitsApp.swift       # App Entry Point, sets up HabitStore and Onboarding
├── Models/
│   ├── Habit.swift           # Domain model for a Habit
│   ├── HabitStore.swift      # Central data manager (Core Data stack + CRUD)
│   └── NotificationManager.swift # Handles scheduling and canceling local notifications
├── Views/
│   ├── Main/                 # Main Tab Views
│   │   ├── MainTabView.swift # Root TabView
│   │   ├── TodayView.swift   # Daily dashboard
│   │   └── HeaderView.swift  # Reusable top header
│   ├── Habits/               # Habit-specific Views
│   │   ├── AddHabitView.swift # Creation/Edit form
│   │   ├── HabitCard.swift   # UI component for a habit
│   │   └── DailyCheckInSection.swift # List of habits for today
│   ├── Statistics/           # Stats Views
│   │   ├── StatsView.swift   # Statistics dashboard
│   │   └── ...               # Charts and Detail views
│   ├── Settings/             # Settings Screens
│   │   ├── SettingsView.swift # Main Settings list
│   │   ├── NotificationsSettingsView.swift # Notification management
│   │   └── ...               # Profile, Theme, Legal pages
│   └── Onboarding/           # Onboarding Flow
│       └── OnboardingView.swift # 3-screen intro flow
├── Components/               # Reusable UI Components
│   ├── BottomTabBar.swift    # Custom floating tab bar
│   ├── WeeklyDatePicker.swift # Horizontal calendar strip
│   ├── GitHubContributionGrid.swift # Heatmap style grid
│   └── ...
└── Utils/
    ├── BottomSheetStyle.swift # Custom sheet modifiers
    └── UIConstants.swift     # Shared constants
```

## 4. Key Components

### Models & Persistence (`HabitStore`)
-   **`Habit`**: A struct representing a habit. It includes properties like `id`, `name`, `emoji`, `color`, `dailyGoal`, `activeWeekdays`, and `currentProgress`.
-   **`HabitStore`**:
    -   Initializes the Core Data stack (`NSPersistentContainer`).
    -   Fetches habits and daily progress entries.
    -   **`habits`**: Published array of all habits.
    -   **`selectedDate`**: Controls which day's data is currently viewed in `TodayView`.
    -   **CRUD**: Methods like `addHabit`, `deleteHabit`, `updateHabitProgress`, `toggleOneTimeHabit`.

### Views
-   **`MainTabView`**: Manages the top-level navigation between Today, Stats, and Settings. It uses a custom `BottomTabBarWithBinding` for a unique look.
-   **`TodayView`**: The primary screen. It shows the `HeaderView`, `AdvancedWeeklyDatePicker`, and the `DailyCheckInSection` (list of habits).
-   **`StatsView`**: Displays global and per-habit statistics. It uses `HabitStatsCard` to show completion rates and "GitHub-style" contribution grids.
-   **`SettingsView`**: A standard list-based settings menu. It handles navigation to sub-settings like Notifications and Profile.
-   **`OnboardingView`**: A 3-page tutorial for new users. It collects the user's name and sets a `hasCompletedOnboarding` flag in `UserDefaults`.

### Notifications
-   **`NotificationManager`**: Singleton responsible for `UNUserNotificationCenter` interactions.
-   **Scheduling**: Notifications are scheduled weekly for specific days/times.
-   **Identifiers**: Uses a format `"{habitUUID}-{weekday}"` to uniquely identify and manage notifications for each habit's active days.
-   **Settings**: `NotificationsSettingsView` lists active habit reminders by querying pending system notifications.

## 5. State Management

-   **`@EnvironmentObject var habitStore: HabitStore`**: Used in almost every view to access shared data.
-   **`@AppStorage`**: Used for simple user preferences:
    -   `"hasCompletedOnboarding"`: Bool
    -   `"profileName"`: String
    -   `"profileAvatarData"`: Data (for the profile picture)

## 6. Design System

-   **Colors**: The app uses a set of custom colors defined in the Asset Catalog (e.g., "backgroundblack", "grayblack", "Lime").
-   **Typography**: Standard system fonts with specific weights (Bold for headers, Medium for body).
-   **Components**:
    -   **`BottomSheetModifier`**: A unified style for sheets (rounded corners, dark background).
    -   **`DynamicTrackingCard`**: A circular progress card for tracking habits.

## 7. Recent Changes (v1.1)

-   **Onboarding**: Added a dedicated onboarding flow (`OnboardingView`) that runs on first launch.
-   **Settings Scroll Fix**: Refactored `SettingsView` to use a fixed header, resolving a scrolling glitch.
-   **Notification Overhaul**: Removed the generic "Daily Reminder" in favor of per-habit reminders. Users can now view and edit reminders directly from the Settings > Notifications page.
