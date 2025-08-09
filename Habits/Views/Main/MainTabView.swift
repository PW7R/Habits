import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: TabType = .today
    
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
                
                // Bottom tab bar
                BottomTabBarWithBinding(selectedTab: $selectedTab)
            }
        }
    }
} 
