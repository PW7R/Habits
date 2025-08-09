import SwiftUI

struct ContactUsView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        ZStack {
            Color("backgroundblack").ignoresSafeArea()

            List {
                Section(header: Text("Contact").foregroundColor(.white)) {
                    Button {
                        if let url = URL(string: "tel:+1234567890") {
                            openURL(url)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "phone")
                                .foregroundColor(.white)
                            Text("Call Us")
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .listRowBackground(Color("grayblack"))

                    Button {
                        if let url = URL(string: "mailto:support@example.com") {
                            openURL(url)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.white)
                            Text("Email Support")
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
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
        .navigationTitle("Contact Us")
    }
}
