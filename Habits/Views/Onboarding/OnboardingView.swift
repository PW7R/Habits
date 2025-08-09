import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("profileName") private var profileName: String = ""
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color("backgroundblack").ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                // Screen 1: Intro
                OnboardingPage(
                    imageName: "sparkles",
                    title: "Welcome to Habits",
                    description: "Build better habits and track your progress every day.",
                    isLastPage: false,
                    action: { withAnimation { currentPage += 1 } }
                )
                .tag(0)
                
                // Screen 2: Features
                OnboardingPage(
                    imageName: "chart.bar.fill",
                    title: "Track Progress",
                    description: "Visualize your success with beautiful charts and statistics.",
                    isLastPage: false,
                    action: { withAnimation { currentPage += 1 } }
                )
                .tag(1)
                
                // Screen 3: Name Input
                OnboardingNamePage(
                    profileName: $profileName,
                    action: {
                        withAnimation {
                            hasCompletedOnboarding = true
                        }
                    }
                )
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        }
    }
}

struct OnboardingPage: View {
    let imageName: String
    let title: String
    let description: String
    let isLastPage: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(Color("Lime"))
                .padding(.bottom, 20)
            
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: action) {
                Text(isLastPage ? "Get Started" : "Next")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("Lime"))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }
}

struct OnboardingNamePage: View {
    @Binding var profileName: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("What's your name?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            TextField("Enter your name", text: $profileName)
                .padding()
                .background(Color("grayblack"))
                .cornerRadius(12)
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .submitLabel(.done)
            
            Spacer()
            
            Button(action: action) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("Lime"))
                    .cornerRadius(12)
            }
            .disabled(profileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(profileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }
}
