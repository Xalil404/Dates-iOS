//
//  SignUpView.swift
//  Dates
//
//  Created by TEST on 31.10.2024.
//
//  SignUpView.swift
//  Dates
//
//  Created by TEST on 31.10.2024.
//

import AuthenticationServices
import GoogleSignIn
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
    
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    @State private var user: User? = nil
    
    // Apple sign up
    @State private var appleSignUpError: String?
    


    
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
                    .frame(width: 200, height: 200)
                
                // Title
                Text("Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    
                
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
                
                
                // Sign in with Apple Button
                            SignInWithAppleButton(
                                .signUp,
                                onRequest: { request in
                                    request.requestedScopes = [.fullName, .email]
                                },
                                onCompletion: { result in
                                    switch result {
                                    case .success(let authorization):
                                        handleAppleSignUp(authorization: authorization)
                                    case .failure(let error):
                                        appleSignUpError = "Apple Sign-Up failed: \(error.localizedDescription)"
                                    }
                                }
                            )
                            .signInWithAppleButtonStyle(.black)
                            .frame(height: 55)
                            .cornerRadius(30)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 10)
                            .shadow(radius: 5)
                            
                            // Error Message for Apple Sign-Up
                            if let error = appleSignUpError {
                                Text(error)
                                    .foregroundColor(.red)
                                    .padding(.top, 10)
                            }
                
                // Login with Google Button
                Button(action: {
                    // Handle Google login action here
                    handleSignupButton() // Call the function to handle sign-in
                }) {
                    HStack {
                        Image("googleIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text("Sign up with Google")
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
            // Assuming you have a state variable to control the navigation
            .fullScreenCover(isPresented: $isSignUpSuccessful) {
                MainTabView() // Navigate to BirthdayListView on successful sign-in
            }
    
        }
    }
    
    


    
    /*Account created in db & accesses the app */
    private func signUp() {
        print("Sign-up process started.")
        
        // Validate that no fields are empty
                guard !username.isEmpty else {
                        alertItem = SignUpError(message: "Username cannot be empty.")
                        print("Username cannot be empty.")
                        return
                    }
                    
                    guard !email.isEmpty else {
                        alertItem = SignUpError(message: "Email cannot be empty.")
                        print("Email cannot be empty.")
                        return
                    }
                    
                    guard !password.isEmpty else {
                        alertItem = SignUpError(message: "Password cannot be empty.")
                        print("Password cannot be empty.")
                        return
                    }
                    
                    guard !confirmPassword.isEmpty else {
                        alertItem = SignUpError(message: "Please confirm your password.")
                        print("Please confirm your password.")
                        return
                    }
        
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
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response Status Code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 201 {
                    print("Registration successful.")
                    DispatchQueue.main.async {
                        self.isSignUpSuccessful = true
                    }
                } else {
                    DispatchQueue.main.async {
                        self.alertItem = SignUpError(message: "Registration successful, but with unexpected status code: \(httpResponse.statusCode). Proceeding to the app.")
                        print("Registration successful, but with unexpected status code: \(httpResponse.statusCode). Proceeding to the app.")
                        self.isSignUpSuccessful = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.alertItem = SignUpError(message: "Unexpected error. Please try again.")
                    print("Unexpected error. No detailed response.")
                }
            }
        }.resume()
    }



    
    /* User registers and goes in app but no account created
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
            
            // Debugging: Print response details
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response Status Code: \(httpResponse.statusCode)")
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response data: \(responseString)")
                }
                
                // Check for successful registration
                if httpResponse.statusCode == 201 || httpResponse.statusCode == 204 {
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
                            self.alertItem = SignUpError(message: "Registration failed with status code: \(httpResponse.statusCode). Please try again.")
                            print("Registration failed with status code: \(httpResponse.statusCode).")
                        }
                    }
                }
            }
        }.resume()
    }
*/
    
   
   
    /* User account created but can't access app */
    /*
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
         */
    
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
    
    
    // Google Sign up
    func handleSignupButton() {
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
                // After successfully signing up, set isSignUpSuccessful to true
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
                            self.isSignUpSuccessful = true
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
    func handleAppleSignUp(authorization: ASAuthorization) {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userID = appleIDCredential.user
                let email = appleIDCredential.email
                
                // Save user data in UserDefaults or send it to your backend
                UserDefaults.standard.set(userID, forKey: "appleUserID")
                UserDefaults.standard.set(email, forKey: "appleEmail")
                
                // Mark sign-up as successful
                self.isSignUpSuccessful = true
            }
        }
    */
    
    
    // Function to handle Apple sign-up
    func handleAppleSignUp(authorization: ASAuthorization) {
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
            
            // Prepare data to send to the backend (for sign-up purposes)
            let appleData: [String: Any] = [
                "apple_token": tokenString,
                "user_id": userID,
                "full_name": "\(fullName?.givenName ?? "") \(fullName?.familyName ?? "")",
                "email": email ?? ""
            ]
            
            // Send the user data to your backend for sign-up (same function for sign-in or sign-up)
            sendAppleDataToBackend(appleData: appleData) { result in
                switch result {
                case .success(let token):
                    // Successfully authenticated/sign-up, save token and set login state
                    UserDefaults.standard.set(token, forKey: "authToken")
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    
                    // Use `self` directly here since `SignUpView` is not a class
                    DispatchQueue.main.async {
                        self.isSignUpSuccessful = true
                        // Proceed with the app flow after successful sign-up
                    }
                case .failure(let error):
                    // Handle error during sign-up
                    print("Apple sign-up failed with error: \(error.localizedDescription)")
                }
            }
        }
    }

    // Function to send Apple Sign-In data to backend
    func sendAppleDataToBackend(appleData: [String: Any], completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://crud-backend-for-react-841cbc3a6949.herokuapp.com/api/auth/apple/mobile/") else {  // Updated for sign-up
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
    
} // View officially ends here

// Two functions for Google Sign in
func getRootViewController() -> UIViewController? {
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



struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}





