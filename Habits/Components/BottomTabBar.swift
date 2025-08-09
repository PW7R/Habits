import SwiftUI

// MARK: - Tab Types
enum TabType: Int, CaseIterable {
    case today = 0
    case stats = 1
    case grid = 2
    
    var icon: Image {
        switch self {
        case .today: return Image("Today")
        case .stats: return Image("Stats")
        case .grid: return Image("Settings")
        }
    }
    
    var title: String {
        switch self {
        case .today: return "Today"
        case .stats: return "Stats"
        case .grid: return "Settings"
        }
    }
}

struct BottomTabBarWithBinding: View {
    @Binding var selectedTab: TabType
    
    var body: some View {
        HStack (spacing: 0){
            ForEach(TabType.allCases, id: \.self) { tab in
                TabButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    action: { selectedTab = tab }
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(tabBarBackground)
        .padding(.bottom, 2)
        .padding(.horizontal, 14)
    }
    
    private var tabBarBackground: some View {
        Capsule()
            .fill(Color("grayblack"))
            .overlay(
                Capsule()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
            )
    }
}

struct TabButton: View {
    let tab: TabType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                tab.icon
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.some(isSelected ? Color(.black) : Color("grayicon")))
                
                if isSelected {
                    Text(tab.title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, isSelected ? 16 : 12)
            .padding(.vertical, 8)
            .background(selectedBackground)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
    }
    
    private var selectedBackground: some View {
        Capsule()
            .fill(isSelected ? Color("Lime") : Color.clear)
    }
}

