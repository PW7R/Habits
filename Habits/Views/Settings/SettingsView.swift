import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var habitStore: HabitStore
    var body: some View {
        ZStack {
            Color("backgroundblack").ignoresSafeArea()
            
            VStack {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                
                Spacer()
                Spacer()
            }
        }
    }
}
