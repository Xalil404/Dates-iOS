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
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .padding(.bottom, 10)
                        
                        Text("Profile")
                            .font(.largeTitle)
                            .padding()
                        Text("Username: \(user.username)") // Display the username
                            .font(.subheadline)
                            .padding()
                    } else {
                        Text("Failed to load user information")
                            .font(.subheadline)
                            .padding()
                    }
                    
                    Spacer()
                    
                    // Logout Button
                    Button(action: {
                        logout() // Call logout function
                    }) {
                        Text("Log Out")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity) // Make the button full width
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal) // Add horizontal padding
                    
                }
                .padding()
                .background(Color(red: 248/255, green: 247/255, blue: 245/255)) // Set background color
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
                .fullScreenCover(isPresented: $isLoggedOut) {
                    LoginView() // Replace with your actual login view
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
    
    /* UI is above; below are the functions */
    private func logout() {
        // Clear the authentication token from UserDefaults
        UserDefaults.standard.removeObject(forKey: "authToken")
        
        // Reset the user data and navigate to the login screen
        user = nil
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
