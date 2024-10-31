//
//  ProfileView.swift
//  Dates
//
//  Created by TEST on 31.10.2024.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode // To dismiss the view
    @State private var isLoggedOut = false // State to track logout

    var body: some View {
        NavigationView {
            VStack {
                Text("Profile")
                    .font(.largeTitle)
                    .padding()
                Text("This is a placeholder for the Profile screen.")
                    .font(.subheadline)
                    .padding()
                
                Spacer()
                
                // Logout Button
                Button(action: {
                    // Handle logout action here
                    logout() // Call logout function
                }) {
                    Text("Log Out")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .padding(.top, 20)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $isLoggedOut) {
                LoginView() // Replace with your actual login view
            }
        }
    }
    
    private func logout() {
        // Perform any necessary logout logic here (e.g., clearing user data)
        // After logging out, update the state to present the login view
        isLoggedOut = true
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
