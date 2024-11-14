//
//  LoginView.swift
//  Dates
//
//  Created by TEST on 31.10.2024.
//

import AuthenticationServices
import GoogleSignIn
import SwiftUI

// Backend URL for google auth
struct API {
    static let backendURL = "https://crud-backend-for-react-841cbc3a6949.herokuapp.com/api/auth/google/mobile/"
}


struct LoginView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var loginError: String?
    @State private var isLoading: Bool = false
    @State private var isLoginSuccessful: Bool = false
    
    @State private var appleSignInError: String?
    
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
                .frame(width: 300, height: 300)
            
            // Title
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            
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
            
            // Login with Apple Button
            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        handleAppleSignIn(authorization: authorization)
                    case .failure(let error):
                        appleSignInError = "Apple Sign-In failed: \(error.localizedDescription)"
                    }
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 55)
            .cornerRadius(30)
            .padding(.horizontal, 40)
            .padding(.bottom, 10)
            .shadow(radius: 5)
            
            // Display error message for Apple Sign-In if any
            if let error = appleSignInError {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
            
            
            // Login with Google Button
            Button(action: {
                // Handle Google login action here
                handleSigninButton() // Call the function to handle sign-in
            }) {
                HStack {
                    Image("googleIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("Sign in with Google")
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
                }
        }
        .background(Color(red: 248/255, green: 247/255, blue: 245/255))
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        
        .onAppear {
            // Ensure we don't automatically login without credentials
            if UserDefaults.standard.bool(forKey: "isLoggedIn") {
                // Only set to true if there's a valid token saved, not just based on the isLoggedIn flag
                if UserDefaults.standard.string(forKey: "authToken") != nil {
                    self.isLoginSuccessful = true
                }
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
    
    
    // Google login
    func handleSigninButton() {
        print("Sign in with Google clicked")
        
        if let rootViewController = getRootViewController() {
            GIDSignIn.sharedInstance.signIn(
                withPresenting: rootViewController
            ) { result, error in
                if let error = error {
                    print("Error signing in: \(error.localizedDescription)")
                    return
                }
                
                guard let result = result else {
                    print("No result")
                    return
                }
                
                // Successful sign-in
                print(result.user.profile?.name)
                print(result.user.profile?.email)
                print(result.user.profile?.imageURL(withDimension: 200))
                // You can do something with the result here, like navigating to another view or storing user info
                // After successfully logging in with Google, set isLoginSuccessful to true
                // Retrieve the ID token and send it to your backend
                if let idToken = result.user.idToken?.tokenString {
                    sendTokenToBackend(idToken: idToken)
                }
            }
        }
    }
    
    
    // Function to send token to backend
    func sendTokenToBackend(idToken: String) {
        guard let url = URL(string: API.backendURL) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create JSON body with the token
        let body: [String: Any] = ["token": idToken]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Failed to serialize JSON body: \(error.localizedDescription)")
            return
        }
        
        // Send the request to your backend
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending token: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received from backend")
                return
            }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                if let dict = jsonResponse as? [String: Any], let token = dict["token"] as? String {
                    // Successfully authenticated, save token and set login state
                    UserDefaults.standard.set(token, forKey: "authToken")
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    DispatchQueue.main.async {
                        self.isLoginSuccessful = true
                    }
                } else {
                    print("Invalid response from backend")
                }
            } catch {
                print("Failed to parse response from backend: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    /*
     // Function to login with Apple without a backend
     func handleAppleSignIn(authorization: ASAuthorization) {
     if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
     // Extract user data
     let userID = appleIDCredential.user
     let fullName = appleIDCredential.fullName
     let email = appleIDCredential.email
     
     // Save user data in UserDefaults or send it to your backend
     UserDefaults.standard.set(userID, forKey: "appleUserID")
     UserDefaults.standard.set(email, forKey: "appleEmail")
     
     // Mark login as successful
     self.isLoginSuccessful = true
     }
     }
     */
    
    // Function to handle Apple sign-in with a backend
    func handleAppleSignIn(authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            // Extract user data
            let userID = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            // Log details for debugging
            print("User ID: \(userID)")
            print("Full Name: \(fullName?.givenName ?? "N/A") \(fullName?.familyName ?? "N/A")")
            print("Email: \(email ?? "N/A")")
            
            // Retrieve the identity token
            guard let identityToken = appleIDCredential.identityToken,
                  let tokenString = String(data: identityToken, encoding: .utf8) else {
                print("Failed to retrieve Apple ID Token")
                return
            }
            
            // Log the token for debugging
            print("Apple ID Token: \(tokenString)")
            
            // Prepare data to send to the backend
            let appleData: [String: Any] = [
                "apple_token": tokenString,
                "user_id": userID,
                "full_name": "\(fullName?.givenName ?? "") \(fullName?.familyName ?? "")",
                "email": email ?? ""
            ]
            
            // Send the user data to your backend for authentication
            sendAppleDataToBackend(appleData: appleData) { result in
                switch result {
                case .success(let token):
                    // Successfully authenticated, save token and set login state
                    UserDefaults.standard.set(token, forKey: "authToken")
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    // Use `self` directly here since `LoginView` is not a class
                    DispatchQueue.main.async {
                        self.isLoginSuccessful = true
                    }
                case .failure(let error):
                    // Handle error
                    print("Apple sign-in failed with error: \(error.localizedDescription)")
                }
            }
        }
    }


    // Function to send Apple Sign-In data to backend
    func sendAppleDataToBackend(appleData: [String: Any], completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://crud-backend-for-react-841cbc3a6949.herokuapp.com/api/auth/apple/mobile/") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: appleData, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        // Send the request to the backend
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            
            // Parse the response
            do {
                if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let token = dict["token"] as? String {
                        completion(.success(token))
                    } else if let errorMessage = dict["error"] as? String {
                        // Handling a potential error message from the backend
                        completion(.failure(NSError(domain: errorMessage, code: 0, userInfo: nil)))
                    } else {
                        completion(.failure(NSError(domain: "Unexpected response format", code: 0, userInfo: nil)))
                    }
                } else {
                    completion(.failure(NSError(domain: "Invalid JSON structure", code: 0, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

}  // View officially ends here


// Two functions for Google Sign in
func getRootViewControllerForLogin() -> UIViewController? {
    guard let scene = UIApplication.shared.connectedScenes.first as?
            UIWindowScene,
          let rootViewController = scene.windows.first?.rootViewController else {
        return nil
    }
    return getVisibleViewController (from: rootViewController)
}


private func getVisibleViewController (from vc: UIViewController) ->
UIViewController {
    if let nav = vc as? UINavigationController {
        return getVisibleViewController(from: nav.visibleViewController!)
    }
    if let tab = vc as? UITabBarController {
        return getVisibleViewController(from: tab.selectedViewController!)
    }
    if let presented = vc.presentedViewController {
        return getVisibleViewController (from: presented)
    }
    return vc
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}


