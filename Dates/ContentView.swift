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

    var body: some View {
        if showSplashScreen {
            SplashScreen()
                .onAppear {
                    // Automatically transition to OnboardingView after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showSplashScreen = false
                        }
                    }
                }
        } else {
            OnboardingView() // Replace with actual OnboardingView when created
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
