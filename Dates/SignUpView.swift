//
//  SignUpView.swift
//  Dates
//
//  Created by TEST on 31.10.2024.
//
import SwiftUI

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack { // Use NavigationStack for better navigation control
            VStack {
                // Back Button
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss() // Navigate back to Welcome screen
                    }) {
                        Image(systemName: "arrow.left") // Back arrow icon
                            .font(.title)
                            .foregroundColor(.black)
                    }
                    Spacer()
                }
                .padding(.top, 50) // Increase this value to lower the button
                .padding(.horizontal)

                // Main Image
                Image("signupImage") // Add your image asset here
                    .resizable()
                    .scaledToFit()
                    .frame(width: 265, height: 265) // Adjust size as needed

                // Title
                Text("Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                // Email Input Field
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "at") // Email icon
                            .foregroundColor(.gray)
                            .padding(.leading, 10)

                        TextField("Email", text: .constant("")) // Replace with your binding
                            .padding(10)
                            .background(Color.clear) // Clear background
                    }

                    Rectangle() // Bottom border
                        .frame(width: 280, height: 1) // Border height
                        .foregroundColor(Color.gray) // Border color
                }
                .padding(.horizontal)

                // Username Input Field
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "person") // Username icon
                            .foregroundColor(.gray)
                            .padding(.leading, 10)

                        TextField("Username", text: .constant("")) // Replace with your binding
                            .padding(10)
                            .background(Color.clear) // Clear background
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

                        SecureField("Password", text: .constant("")) // Replace with your binding
                            .padding(10)
                            .background(Color.clear) // Clear background
                    }

                    Rectangle() // Bottom border
                        .frame(width: 280, height: 1) // Border height
                        .foregroundColor(Color.gray) // Border color
                }
                .padding(.horizontal)

                // Confirm Password Input Field
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "lock") // Confirm Password icon
                            .foregroundColor(.gray)
                            .padding(.leading, 10)

                        SecureField("Confirm Password", text: .constant("")) // Replace with your binding
                            .padding(10)
                            .background(Color.clear) // Clear background
                    }

                    Rectangle() // Bottom border
                        .frame(width: 280, height: 1) // Border height
                        .foregroundColor(Color.gray) // Border color
                }
                .padding(.horizontal)

                // Continue Button
                Button(action: {
                    // Handle sign up action here
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
            }
            .background(Color(red: 248/255, green: 247/255, blue: 245/255)) // Set background color
            .edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden(true) // Hide the default back button
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
