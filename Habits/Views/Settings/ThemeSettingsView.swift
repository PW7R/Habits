import SwiftUI

struct ThemeSettingsView: View {
    var body: some View {
        ZStack {
            Color("backgroundblack").ignoresSafeArea()
            
            List {
                Section(header: Text("Theme").foregroundColor(.white)) {
                    HStack {
                        Text("Theme options coming soon")
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .listRowBackground(Color("grayblack"))
                }
            }
            .environment(\.defaultMinListHeaderHeight, 0)
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .listStyle(.insetGrouped)
            .tint(Color("Lime"))
        }
        .navigationTitle("Theme")
    }
}
