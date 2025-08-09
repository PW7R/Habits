import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ZStack {
            Color("backgroundblack").ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Terms of Service")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Group {
                        Text("By using this app, you agree to the following terms:")
                        Text("• This app is provided as-is, without warranties of any kind.")
                        Text("• You are responsible for your use of the app and your data.")
                        Text("• Features may change or be discontinued without prior notice.")
                    }
                    .foregroundColor(.white.opacity(0.9))
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Terms of Service")
    }
}
