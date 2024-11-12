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
    @State private var user: User? // State variable to hold user data
    @State private var isLoading = true // State variable to track loading state
    @State private var errorMessage: String = "" // State variable to hold error messages
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    Text("Loading user information...")
                        .font(.headline)
                        .padding()
                } else if let user = user {
                    // Circular profile image
                    Image("defaultProfileImage") // Replace with your image name or use a system image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 300, height: 300)
                        .clipShape(Circle())
                        .padding(.bottom, 10)
                    
                    Text("Username: \(user.username)") // Display the username
                        .font(.largeTitle)
                        .padding(.bottom, 10) // Add bottom padding to separate from logout button
                    
                    // Logout Button
                    Button(action: {
                        logout() // Call logout function
                    }) {
                        Text("Log Out")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity) // Make the button full width
                            .background(Color.red)
                            .cornerRadius(8)
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                            .shadow(radius: 5)
                    }
                    .padding(.top, 10) // Optional: Add some top padding if needed
                    .padding(.horizontal) // Add horizontal padding
                    
                    // Information and button to close account
                    VStack(alignment: .center) {
                        Text("To close your account and delete your data and profile, submit an account closure request.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                                            
                                            // Button to navigate to the URL
                                            Button(action: {
                                                if let url = URL(string: "https://crud-frontend-steel.vercel.app/contact") {
                                                    UIApplication.shared.open(url)
                                                }
                                            }) {
                                                Text("Press here to delete your account")
                                                    .foregroundColor(.blue) // Customize the button text color
                                                    .font(.body)
                                            }
                                            .padding(.top, 5)
                                        }
                                        .padding(.top, 30) // Add top padding to separate from the logout button
                    
                } else {
                    Text("Failed to load user information")
                        .font(.subheadline)
                        .padding()
                }
                
                Spacer() // Keep this for pushing content up if needed
            }
            .padding()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            
            .fullScreenCover(isPresented: $isLoggedOut) {
                WelcomeView() // Replace with your actual login view
            }
            
            .onAppear {
                fetchUserProfile() // Fetch user data when the view appears
            }
            .alert(isPresented: Binding<Bool>(
                get: { !errorMessage.isEmpty },
                set: { if !$0 { errorMessage = "" }}
            )) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func logout() {
        // Clear the authentication token from UserDefaults
        UserDefaults.standard.removeObject(forKey: "authToken")
        
        // Reset the user data
        user = nil
        
        // Debug print to verify logout
        print("User logged out. Setting isLoggedOut to true.")
        
        // Trigger the fullScreenCover to show the LoginView
        isLoggedOut = true
    }
    

    private func fetchUserProfile() {
        guard let token = UserDefaults.standard.string(forKey: "authToken"),
              let url = URL(string: "https://crud-backend-for-react-841cbc3a6949.herokuapp.com/api/profile/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
                return
            }

            guard let data = data else { return }

            do {
                let fetchedUser = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    self.user = fetchedUser
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to decode user data."
                    isLoading = false
                }
            }
        }.resume()
    }
}



struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
