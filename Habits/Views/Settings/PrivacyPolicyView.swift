import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ZStack {
            Color("backgroundblack").ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Privacy Policy")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Group {
                        Text("We respect your privacy.")
                        Text("This app stores your habits and profile preferences (such as your name and avatar) locally on your device. We do not collect, sell, or share your personal data.")
                        Text("If you enable notifications, the app will schedule local notifications on your device using Apple's notification APIs.")
                        Text("You can revoke notification permissions at any time from System Settings.")
                    }
                    .foregroundColor(.white.opacity(0.9))
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Privacy Policy")
    }
}
