//
//  LoginView.swift
//  Dates
//
//  Created by TEST on 31.10.2024.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var loginError: String?
    @State private var isLoading: Bool = false
    @State private var isLoginSuccessful: Bool = false

    var body: some View {
        VStack {
            // Custom Back Button
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title)
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.top, 50)
            .padding(.horizontal)

            // Main Image
            Image("loginImage")
                .resizable()
                .scaledToFit()
                .frame(width: 350, height: 350)

            // Title
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            // Email Input Field
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "at")
                        .foregroundColor(.gray)
                        .padding(.leading, 10)

                    TextField("Email", text: $email)
                        .padding(10)
                        .background(Color.clear)
                        .autocapitalization(.none)
                }

                Rectangle()
                    .frame(width: 280, height: 1)
                    .foregroundColor(Color.gray)
            }
            .padding(.horizontal)

            // Password Input Field
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.gray)
                        .padding(.leading, 10)

                    SecureField("Password", text: $password)
                        .padding(10)
                        .background(Color.clear)
                }

                Rectangle()
                    .frame(width: 280, height: 1)
                    .foregroundColor(Color.gray)
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
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .background(Color.gray)
                Text("or")
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                Divider()
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .background(Color.gray)
            }
            .padding(.vertical)
            .padding(.horizontal, 40)

            // Login with Google Button
            Button(action: {
                // Handle Google login action here
            }) {
                HStack {
                    Image("googleIcon")
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
                .fullScreenCover(isPresented: $isLoginSuccessful) {
                            MainTabView()
            /*
            NavigationLink(
                destination: MainTabView(),
                isActive: $isLoginSuccessful
            ) {
                EmptyView()
             */
            }
        }
        .background(Color(red: 248/255, green: 247/255, blue: 245/255))
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Check if user is already logged in
            if UserDefaults.standard.bool(forKey: "isLoggedIn") {
                self.isLoginSuccessful = true
            }
        }
    }
    
    /* Ui is above; below are the functions */

    // Function to handle user login
    private func loginUser(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            loginError = "Email and password cannot be empty."
            return
        }

        isLoading = true
        loginError = nil

        let credentials = ["email": email, "password": password]
        let loginUrl = "https://crud-backend-for-react-841cbc3a6949.herokuapp.com/auth/login/"

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
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                if let dict = jsonResponse as? [String: Any], let token = dict["key"] as? String {
                    // Login successful, save the token and login state
                    UserDefaults.standard.set(token, forKey: "authToken")
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.isLoginSuccessful = true
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
        
        task.resume()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}


