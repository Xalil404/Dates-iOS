//
//  DatesApp.swift
//  Dates
//
//  Created by TEST on 31.10.2024.
//
import GoogleSignIn
import SwiftUI

@main
struct DatesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onOpenURL { url in
                                    GIDSignIn.sharedInstance.handle(url)  // Handle the URL for Google Sign-In
                                }
        }
    }
}



