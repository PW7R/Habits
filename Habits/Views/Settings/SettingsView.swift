import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

struct SettingsView: View {
    @EnvironmentObject var habitStore: HabitStore
    @AppStorage("profileName") private var profileName: String = ""
    @AppStorage("profileAvatarData") private var profileAvatarData: Data?
    
    private var displayName: String { profileName.isEmpty ? "User" : profileName }

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
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 10)
                
                List {
                    // Profile header (non-interactive avatar + name)
                    Section {
                        VStack(spacing: 8) {
                            HStack {
                                Spacer()
                                avatarImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 96, height: 96)
                                    .clipShape(Circle())
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            Text(displayName)
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .listRowBackground(Color.clear)
                    }
                    
                    // Quick access to detailed profile page
                    Section(footer: EmptyView()) {
                        NavigationLink(destination: ProfileSettingsView()) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.crop.circle")
                                    .foregroundColor(.white)
                                Text("Profile")
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                        .listRowBackground(Color("grayblack"))
                    }
                    
                    // Habits
                    Section(header: Text("Habits").foregroundColor(.white)) {
                        NavigationLink(destination: ReorderHabitsView()) {
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.up.arrow.down").foregroundColor(.white)
                                Text("Reorder Habits").foregroundColor(.white)
                                Spacer()
                            }
                        }
                        .listRowBackground(Color("grayblack"))
                    }
                    
                    // App
                    Section(header: Text("App").foregroundColor(.white)) {
                        NavigationLink(destination: NotificationsSettingsView()) {
                            HStack(spacing: 12) {
                                Image(systemName: "bell.badge").foregroundColor(.white)
                                Text("Notifications").foregroundColor(.white)
                                Spacer()
                            }
                        }
                        .listRowBackground(Color("grayblack"))
                        
                        NavigationLink(destination: ThemeSettingsView()) {
                            HStack(spacing: 12) {
                                Image(systemName: "paintbrush").foregroundColor(.white)
                                Text("Theme").foregroundColor(.white)
                                Spacer()
                            }
                        }
                        .listRowBackground(Color("grayblack"))
                    }
                    
                    // Support
                    Section(header: Text("Support").foregroundColor(.white)) {
                        NavigationLink(destination: ContactUsView()) {
                            HStack(spacing: 12) {
                                Image(systemName: "phone").foregroundColor(.white)
                                Text("Contact Us").foregroundColor(.white)
                                Spacer()
                            }
                        }
                        .listRowBackground(Color("grayblack"))
                    }
                    
                    // Legal
                    Section(header: Text("Legal").foregroundColor(.white)) {
                        NavigationLink(destination: PrivacyPolicyView()) {
                            HStack(spacing: 12) {
                                Image(systemName: "lock.shield").foregroundColor(.white)
                                Text("Privacy Policy").foregroundColor(.white)
                                Spacer()
                            }
                        }
                        .listRowBackground(Color("grayblack"))
                        
                        NavigationLink(destination: TermsOfServiceView()) {
                            HStack(spacing: 12) {
                                Image(systemName: "doc.text").foregroundColor(.white)
                                Text("Terms of Service").foregroundColor(.white)
                                Spacer()
                            }
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
            .background(Color("backgroundblack").ignoresSafeArea())
        }
    }
}



