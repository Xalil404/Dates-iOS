//
//  LoginView.swift
//  Dates
//
//  Created by TEST on 31.10.2024.
//
import SwiftUI

struct LoginView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String = "" // State variable for email
    @State private var password: String = "" // State variable for password
    @State private var loginError: String? // State variable for storing login error messages
    @State private var isLoading: Bool = false // State variable to manage loading state
    @State private var isLoginSuccessful: Bool = false // State variable to trigger navigation

    var body: some View {
        VStack {
            // Custom Back Button
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss() // Navigate back if necessary
                }) {
                    Image(systemName: "arrow.left") // Back arrow icon
                        .font(.title)
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.top, 50) // Adjust position as needed
            .padding(.horizontal)

            // Main Image
            Image("loginImage") // Add your image asset here
                .resizable()
                .scaledToFit()
                .frame(width: 350, height: 350) // Adjust size as needed

            // Title
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            // Email Input Field
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "at") // Email icon
                        .foregroundColor(.gray)
                        .padding(.leading, 10)

                    TextField("Email", text: $email) // Bind email state
                        .padding(10)
                        .background(Color.clear) // Clear background
                        .autocapitalization(.none) // Prevent autocapitalization
                }

                Rectangle() // Bottom border
                    .frame(width: 280, height: 1) // Border height
                    .foregroundColor(Color.gray) // Border color
            }
            .padding(.horizontal)

            // Password Input Field
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "lock") // Password icon
                        .foregroundColor(.gray)
                        .padding(.leading, 10)

                    SecureField("Password", text: $password) // Bind password state
                        .padding(10)
                        .background(Color.clear) // Clear background
                }

                Rectangle() // Bottom border
                    .frame(width: 280, height: 1) // Border height
                    .foregroundColor(Color.gray) // Border color
            }
            .padding(.horizontal)

            // Error Message
            if let error = loginError {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }

            // Loading Indicator
            if isLoading {
                ProgressView()
                    .padding(.top, 10)
            }

            // Continue Button
            Button(action: {
                // Handle login action here
                loginUser(email: email, password: password)
            }) {
                Text("Continue")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 232/255, green: 191/255, blue: 115/255))
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
            }

            // Divider
            HStack {
                Divider()
                    .frame(maxWidth: .infinity) // Makes the divider stretch horizontally
                    .frame(height: 1) // Height of the line
                    .background(Color.gray) // Optional: Set the line color
                Text("or")
                    .foregroundColor(.gray)
                    .padding(.horizontal) // Add horizontal padding for spacing
                Divider()
                    .frame(maxWidth: .infinity) // Makes the divider stretch horizontally
                    .frame(height: 1) // Height of the line
                    .background(Color.gray) // Optional: Set the line color
            }
            .padding(.vertical)
            .padding(.horizontal, 40)

            // Login with Google Button
            Button(action: {
                // Handle Google login action here
            }) {
                HStack {
                    Image("googleIcon") // Add your Google icon asset here
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("Login with Google")
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(30)
                .padding(.horizontal, 40)
                .shadow(radius: 5)
            }

            Spacer()

            // Navigation Link for CRUD Birthdays Screen
            NavigationLink(
                destination: MainTabView(), // Navigate to the MainTabView on successful login
                isActive: $isLoginSuccessful
            ) {
                EmptyView()
            }
        }
        .background(Color(red: 248/255, green: 247/255, blue: 245/255)) // Set background color
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true) // Hide the default back button, although it shouldn't appear now
    }

    // Function to handle user login
    private func loginUser(email: String, password: String) {
        // Ensure inputs are not empty
        guard !email.isEmpty, !password.isEmpty else {
            loginError = "Email and password cannot be empty."
            return
        }

        // Set loading state
        isLoading = true
        loginError = nil // Reset error message

        // Prepare the credentials for API call
        let credentials = ["email": email, "password": password]

        // API URL for login
        let loginUrl = "https://crud-backend-for-react-841cbc3a6949.herokuapp.com/auth/login/"

        // Make the API call
        guard let url = URL(string: loginUrl) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: credentials, options: [])
        } catch {
            loginError = "Failed to serialize request body."
            isLoading = false
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.loginError = error.localizedDescription
                    self.isLoading = false
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.loginError = "No data received."
                    self.isLoading = false
                }
                return
            }

            do {
                // Attempt to decode the response
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                if let dict = jsonResponse as? [String: Any], let token = dict["key"] as? String {
                    // Login successful, save the token or user info
                    UserDefaults.standard.set(token, forKey: "authToken") // Store token for later use
                    DispatchQueue.main.async {
                        print("Login successful! Token: \(token)")
                        self.isLoading = false
                        self.isLoginSuccessful = true // Trigger navigation
                    }
                } else {
                    DispatchQueue.main.async {
                        self.loginError = "Invalid email or password."
                        self.isLoading = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.loginError = "Failed to parse response."
                    self.isLoading = false
                }
            }
        }
        
        task.resume() // Start the network task
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
