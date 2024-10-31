//
//  WelcomeView.swift
//  Dates
//
//  Created by TEST on 31.10.2024.
//
// WelcomeView.swift
import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("Welcome to Dates")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Image("welcomeImage")
                .resizable()
                .scaledToFit()
                .frame(width: 350, height: 350)
                .padding(.top, 20)
            
            Spacer()
            
            VStack(spacing: 20) {
                // NavigationLink for Login
                NavigationLink(destination: LoginView()) {
                    Text("L o g i n")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 232/255, green: 191/255, blue: 115/255))
                        .foregroundColor(.black)
                        .cornerRadius(30)
                }
                .padding(.horizontal, 40)

                // NavigationLink for Sign Up
                NavigationLink(destination: SignUpView()) {
                    Text("S i g n  U p")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
                .padding(.horizontal, 40)
            }
            .padding(.bottom, 40)
        }
        .background(Color(red: 248/255, green: 247/255, blue: 245/255)) // Set background color
        .edgesIgnoringSafeArea(.all)
        .navigationTitle("") // Set title to empty
        .navigationBarBackButtonHidden(true) // Hide the default back button
        .navigationBarTitleDisplayMode(.inline) // Ensure the title doesn't cause a back button
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // Wrap the preview in a NavigationView for proper simulation
            WelcomeView()
        }
    }
}
