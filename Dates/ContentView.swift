//
//  ContentView.swift
//  Dates
//
//  Created by TEST on 31.10.2024.
//
import SwiftUI
import CoreData

struct ContentView: View {
    @State private var showSplashScreen = true
    @State private var isLoggedOut = false // State to track the user's login status
    @State private var hasSeenOnboardingView = UserDefaults.standard.bool(forKey: "hasSeenOnboardingView") // Track onboarding status
    
    var body: some View {
        if showSplashScreen {
            SplashScreen()
                .onAppear {
                    // Automatically transition to the next view after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showSplashScreen = false
                        }
                    }
                }
        } else {
            // Determine the appropriate view based on user login status and onboarding completion
            if isLoggedOut {
                LoginView() // Show login view when the user is logged out
                    .onAppear {
                        // Reset the onboarding status when showing login view
                        hasSeenOnboardingView = false
                    }
            } else if !hasSeenOnboardingView {
                OnboardingView()
                    .onDisappear {
                        // Set onboarding completion in UserDefaults when onboarding is done
                        UserDefaults.standard.set(true, forKey: "hasSeenOnboardingView")
                    }
            } else {
                MainTabView() // Show the main app view for logged-in users
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


