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
    @State private var isAuthenticated = false // Tracks user authentication
    @State private var hasSeenOnboardingView = UserDefaults.standard.bool(forKey: "hasSeenOnboardingView") // Tracks onboarding completion
    
    var body: some View {
        if showSplashScreen {
            SplashScreen()
                .onAppear {
                    // Simulate splash screen delay and check app state
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            // Always check the authentication and onboarding state on app launch
                            isAuthenticated = checkAuthenticationStatus()
                            showSplashScreen = false
                        }
                    }
                }
        } else {
            // Determine which view to show based on state
            if !hasSeenOnboardingView {
                OnboardingView()
                    .onDisappear {
                        // Mark onboarding as completed
                        UserDefaults.standard.set(true, forKey: "hasSeenOnboardingView")
                        hasSeenOnboardingView = true
                    }
            } else if !isAuthenticated {
                LoginView() // Show login screen if not authenticated
            } else {
                MainTabView() // Show main app view for authenticated users
            }
        }
    }


    /// Function to check if the user is authenticated
    private func checkAuthenticationStatus() -> Bool {
        // Replace this logic with your actual authentication check
        return UserDefaults.standard.bool(forKey: "isAuthenticated")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
/*
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
                WelcomeView() // Show login view when the user is logged out
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
*/


