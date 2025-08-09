import SwiftUI
import PhotosUI
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

struct ProfileSettingsView: View {
    @AppStorage("profileName") private var profileName: String = ""
    @AppStorage("profileAvatarData") private var profileAvatarData: Data?
    
    @State private var selectedItem: PhotosPickerItem?
    
    private var avatarImage: Image {
        if let data = profileAvatarData {
            #if canImport(UIKit)
            if let uiImage = UIImage(data: data) {
                return Image(uiImage: uiImage)
            }
            #elseif canImport(AppKit)
            if let nsImage = NSImage(data: data) {
                return Image(nsImage: nsImage)
            }
            #endif
        }
        return Image(systemName: "person.crop.circle.fill")
    }
    
    var body: some View {
        ZStack {
            Color("backgroundblack").ignoresSafeArea()
            
            List {
                Section(header: Text("Profile").foregroundColor(.white)) {
                    HStack(spacing: 12) {
                        Text("Name")
                            .foregroundColor(.white)
                        Spacer()
                        TextField("Your name", text: $profileName)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color("grayblack"))
                    
                    HStack(spacing: 12) {
                        avatarImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                        
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            HStack {
                                Text("Choose Avatar from Photos")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "photo.on.rectangle")
                                    .foregroundColor(.gray)
                            }
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
        .navigationTitle("Profile")
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    // Optionally compress/normalize
                    profileAvatarData = data
                }
            }
        }
    }
}
