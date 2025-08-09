import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

struct HeaderView: View {
    @EnvironmentObject var habitStore: HabitStore
    @AppStorage("profileName") private var profileName: String = ""
    @AppStorage("profileAvatarData") private var profileAvatarData: Data?
    @State private var showingNotifications = false
    @State private var showingProfile = false

    private var displayName: String {
        profileName.isEmpty ? "User" : profileName
    }

    private var avatarImage: Image {
        if let data = profileAvatarData {
            #if canImport(UIKit)
            if let uiImage = UIImage(data: data) { return Image(uiImage: uiImage) }
            #elseif canImport(AppKit)
            if let nsImage = NSImage(data: data) { return Image(nsImage: nsImage) }
            #endif
        }
        return Image(systemName: "person.crop.circle.fill")
    }
    
    private var monthFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "MMMM"
        return f
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hi, \(displayName) 👋")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(monthFormatter.string(from: habitStore.displayedMonthDate))
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
            }

            Spacer()

            HStack(spacing: 12) {
                Button(action: { showingNotifications = true }) {
                    Image(systemName: "bell")
                        .foregroundColor(.white)
                        .font(.title3)
                }
                Button(action: { showingProfile = true }) {
                    avatarImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .sheet(isPresented: $showingNotifications) {
            NotificationsSettingsView()
                .bottomSheetStyle()
        }
        .sheet(isPresented: $showingProfile) {
            ProfileSettingsView()
                .bottomSheetStyle()
        }
    }
}

