import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var habitStore: HabitStore
    @State private var selectedTab: TabType = .today
    @State private var tabBarHeight: CGFloat = 0
    @State private var showingAddHabit: Bool = false
    
    var body: some View {
        ZStack {
            Color("backgroundblack").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Main content area
                TabView(selection: $selectedTab) {
                    TodayView()
                        .tag(TabType.today)
                    
                    StatsView()
                        .tag(TabType.stats)
                    
                    SettingsView()
                        .tag(TabType.grid)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .safeAreaInset(edge: .bottom) { Color.clear.frame(height: tabBarHeight) }
                
                // Bottom tab bar
                BottomTabBarWithBinding(selectedTab: $selectedTab, onAddHabit: { showingAddHabit = true })
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: TabBarHeightKey.self, value: proxy.size.height)
                        }
                    )
            }
            .onPreferenceChange(TabBarHeightKey.self) { tabBarHeight = $0 }
        }
        .sheet(isPresented: $showingAddHabit) {
            AddHabitView()
                .environmentObject(habitStore)
                .bottomSheetStyle()
        }
    }
}

// PreferenceKey to propagate measured tab bar height up the view tree
private struct TabBarHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

