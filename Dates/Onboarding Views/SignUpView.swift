//
//  SignUpView.swift
//  Dates
//
//  Created by TEST on 31.10.2024.
//

import SwiftUI

struct SignUpError: Identifiable {
    let id = UUID()
    let message: String
}

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var alertItem: SignUpError?
    @State private var isSignUpSuccessful: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                // Back Button
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
                Image("signupImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 265, height: 265)

                // Title
                Text("Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                // Email Input Field
                inputField(icon: "at", placeholder: "Email", text: $email)

                // Username Input Field
                inputField(icon: "person", placeholder: "Username", text: $username)

                // Password Input Field
                inputField(icon: "lock", placeholder: "Password", text: $password, isSecure: true)

                // Confirm Password Input Field
                inputField(icon: "lock", placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)

                // Continue Button
                Button(action: {
                    signUp()
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
            }
            .background(Color(red: 248/255, green: 247/255, blue: 245/255))
            .edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden(true)
            .alert(item: $alertItem) { error in
                Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
            }
            .navigate(to: BirthdayListView(), when: $isSignUpSuccessful)
        }
    }
    
    private func signUp() {
        print("Sign-up process started.")
        
        // Validate input
        guard password == confirmPassword else {
            alertItem = SignUpError(message: "Passwords do not match.")
            print("Passwords do not match.")
            return
        }
        
        // Prepare the request
        guard let url = URL(string: "https://crud-backend-for-react-841cbc3a6949.herokuapp.com/auth/registration/") else {
            alertItem = SignUpError(message: "Invalid URL.")
            print("Invalid URL.")
            return
        }
        
        let parameters: [String: Any] = [
            "username": username,
            "email": email,
            "password1": password,
            "password2": confirmPassword
        ]
        
        print("Preparing request with parameters: \(parameters)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encode parameters as JSON
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            print("Request body: \(String(data: request.httpBody!, encoding: .utf8) ?? "nil")")
        } catch {
            alertItem = SignUpError(message: "Error encoding parameters: \(error.localizedDescription)")
            print("Error encoding parameters: \(error.localizedDescription)")
            return
        }

        // Perform the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.alertItem = SignUpError(message: "Network error: \(error.localizedDescription)")
                    print("Network error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.alertItem = SignUpError(message: "No data received.")
                    print("No data received.")
                }
                return
            }

            // Debugging: Print response data
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response data: \(responseString)")
            }

            // Check for successful registration
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                print("Registration successful.")
                DispatchQueue.main.async {
                    self.isSignUpSuccessful = true
                }
            } else {
                // Parse error message
                if let responseData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let detail = responseData["detail"] as? String {
                    DispatchQueue.main.async {
                        self.alertItem = SignUpError(message: detail)
                        print("Error from server: \(detail)")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.alertItem = SignUpError(message: "Registration failed. Please try again.")
                        print("Registration failed. No detailed error message.")
                    }
                }
            }
        }.resume()
    }
    
    // Input Field Function
    private func inputField(icon: String, placeholder: String, text: Binding<String>, isSecure: Bool = false) -> some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                    .padding(.leading, 10)

                if isSecure {
                    SecureField(placeholder, text: text)
                        .padding(10)
                        .background(Color.clear)
                } else {
                    TextField(placeholder, text: text)
                        .padding(10)
                        .background(Color.clear)
                }
            }

            Rectangle()
                .frame(width: 280, height: 1)
                .foregroundColor(Color.gray)
        }
        .padding(.horizontal)
    }
}

// Navigation Extension
extension View {
    func navigate<Destination: View>(to destination: Destination, when binding: Binding<Bool>) -> some View {
        self.background(
            NavigationLink(
                destination: destination,
                isActive: binding,
                label: { EmptyView() }
            )
        )
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
