//
//  AnniversaryListView.swift
//  Dates
//
//  Created by TEST on 31.10.2024.
//

import SwiftUI

struct AnniversaryListView: View {
    @State private var anniversaries: [Anniversary] = []
    @State private var showAddAnniversary = false
    @State private var anniversaryToEdit: Anniversary? = nil
    @State private var errorMessage: String = ""
    

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // Set the background color here
                Color(red: 248/255, green: 247/255, blue: 245/255) // Set background color to fill the entire screen
                    .edgesIgnoringSafeArea(.all) // Make it fill the entire screen

                // Check if the list is empty
                if anniversaries.isEmpty {
                    // Empty state UI
                    VStack {
                        Image("emptyState")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                            .foregroundColor(.white)
                        
                        Text("No Anniversaries Yet")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.top, 10)
                        
                        Text("Add your first anniversary to keep track of special dates.")
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 5)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Stacked floating bars for each anniversary
                    ScrollView {
                        VStack(spacing: 20) {  // Space between each card
                            ForEach(anniversaries) { anniversary in
                                VStack {
                                    HStack {
                                        // Circular ellipsis button with menu for edit and delete
                                        Menu {
                                            Button("Edit") {
                                                anniversaryToEdit = anniversary
                                                showAddAnniversary.toggle()
                                            }
                                            Button(role: .destructive) {
                                                if let index = anniversaries.firstIndex(where: { $0.id == anniversary.id }) {
                                                    deleteAnniversary(at: IndexSet(integer: index))
                                                }
                                            } label: {
                                                Text("Delete")
                                            }
                                        } label: {
                                            Image(systemName: "ellipsis")
                                                .font(.title2)
                                                .foregroundColor(.white)
                                                .padding(12)
                                                .background(Color.black.opacity(0.6))
                                                .clipShape(Circle())
                                        }
                                        
                                        // Title and Date side by side
                                        Text(anniversary.description.prefix(20) + (anniversary.description.count > 20 ? "..." : ""))
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                        
                                        Spacer()
                                        
                                        Text("Date: \(anniversary.date)")
                                            .font(.subheadline)
                                            .foregroundColor(.black.opacity(0.7))
                                            .fontWeight(.bold)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 75) // Set consistent height
                                    .background(Color(red: 242/255, green: 164/255, blue: 161/255)) // Peach Pink


                                    .cornerRadius(12)
                                    .shadow(radius: 5)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
                
                // Add Anniversary button
                Button(action: {
                    anniversaryToEdit = nil // Reset for adding a new anniversary
                    showAddAnniversary.toggle()
                }) {
                    Text("Add Anniversary")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 232/255, green: 191/255, blue: 115/255))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
                .shadow(radius: 5)
            }
            .navigationTitle("Anniversaries")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAddAnniversary) {
                if let selectedAnniversary = anniversaryToEdit {
                    AddAnniversaryView(onAddAnniversary: { updatedAnniversary in
                        updateAnniversary(anniversary: updatedAnniversary)
                    }, anniversary: selectedAnniversary)
                } else {
                    AddAnniversaryView(onAddAnniversary: { newAnniversary in
                        addAnniversary(anniversary: newAnniversary)
                    })
                }
            }
            .onAppear {
                fetchAnniversaries()
            }
            .alert(isPresented: Binding<Bool>(
                get: { !errorMessage.isEmpty },
                set: { if !$0 { errorMessage = "" }}
            )) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    /* Add & edit Anniversary modal */
    struct AddAnniversaryView: View {
        @Environment(\.presentationMode) var presentationMode
        @State private var description: String = ""
        @State private var date: Date = Date() // Change to Date type
        var onAddAnniversary: (Anniversary) -> Void
        var anniversary: Anniversary?

        var body: some View {
            ZStack {
                Color(red: 242/255, green: 164/255, blue: 161/255) // Modal background color
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Text(anniversary == nil ? "Add Anniversary" : "Edit Anniversary") // Dynamic title
                        .font(.largeTitle)
                        .foregroundColor(.white)

                    // Input field for anniversary description
                    TextField("What's the special occasion?", text: $description)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .foregroundColor(.black)

                    // Date picker without calendar icon
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                        .background(Color.white) // Ensuring the DatePicker is clickable
                        .cornerRadius(8)

                    // HStack for Cancel and Add/Update buttons
                    HStack {
                        // Cancel Button
                        Button(action: {
                            presentationMode.wrappedValue.dismiss() // Dismiss the modal
                        }) {
                            Text("Cancel")
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red) // Color for the cancel button
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .shadow(radius: 5)
                        .padding(.trailing) // Add space between buttons

                        // Add/Update Anniversary Button
                        Button(action: {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd"
                            let dateString = formatter.string(from: date)

                            // Create new Anniversary object based on existing data or a new entry
                            let newAnniversary = Anniversary(id: anniversary?.id ?? 0, user: anniversary?.user ?? 1, description: description, date: dateString)

                            onAddAnniversary(newAnniversary) // Trigger the callback
                            presentationMode.wrappedValue.dismiss() // Dismiss the modal after adding/updating
                        }) {
                            Text(anniversary == nil ? "Add Moment" : "Update Event")
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 232/255, green: 191/255, blue: 115/255)) // Customize button color
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .shadow(radius: 5)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding()
            }
            .onAppear {
                // Populate the fields if editing an existing anniversary
                if let anniversary = anniversary {
                    description = anniversary.description
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    if let dateValue = formatter.date(from: anniversary.date) {
                        self.date = dateValue
                    }
                }
            }
        }
    }

     /* Ui is above; below are the functions */
    
    func fetchAnniversaries() {
        guard let token = UserDefaults.standard.string(forKey: "authToken"),
              let url = URL(string: "https://crud-backend-for-react-841cbc3a6949.herokuapp.com/api/anniversaries/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                }
                return
            }

            guard let data = data else { return }

            do {
                let fetchedAnniversaries = try JSONDecoder().decode([Anniversary].self, from: data)
                DispatchQueue.main.async {
                    self.anniversaries = fetchedAnniversaries
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to decode data."
                }
            }
        }.resume()
    }

    func addAnniversary(anniversary: Anniversary) {
        guard let token = UserDefaults.standard.string(forKey: "authToken"),
              let url = URL(string: "https://crud-backend-for-react-841cbc3a6949.herokuapp.com/api/anniversaries/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = [
            "user": anniversary.user,
            "description": anniversary.description,
            "date": anniversary.date
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                }
                return
            }

            DispatchQueue.main.async {
                fetchAnniversaries() // Refresh the list after adding
            }
        }.resume()
    }

    func updateAnniversary(anniversary: Anniversary) {
        guard let token = UserDefaults.standard.string(forKey: "authToken"),
              let url = URL(string: "https://crud-backend-for-react-841cbc3a6949.herokuapp.com/api/anniversaries/\(anniversary.id)/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT" // Use PUT for updates
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = [
            "user": anniversary.user,
            "description": anniversary.description,
            "date": anniversary.date
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                }
                return
            }

            DispatchQueue.main.async {
                fetchAnniversaries() // Refresh the list after updating
            }
        }.resume()
    }

    func deleteAnniversary(at offsets: IndexSet) {
        for index in offsets {
            let anniversaryId = anniversaries[index].id
            guard let token = UserDefaults.standard.string(forKey: "authToken"),
                  let url = URL(string: "https://crud-backend-for-react-841cbc3a6949.herokuapp.com/api/anniversaries/\(anniversaryId)/") else { return }

            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        errorMessage = error.localizedDescription
                    }
                    return
                }

                DispatchQueue.main.async {
                    self.anniversaries.remove(at: index) // Remove from the array after deleting
                }
            }.resume()
        }
    }
}

/* Original add / edit modal
struct AddAnniversaryView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var description: String = ""
    @State private var date: Date = Date() // Change to Date type
    var onAddAnniversary: (Anniversary) -> Void
    var anniversary: Anniversary?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Anniversary Details")) {
                    TextField("Description", text: $description)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                }

                Button(anniversary == nil ? "Add Anniversary" : "Update Anniversary") {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    let dateString = formatter.string(from: date)
                    let newAnniversary = Anniversary(id: anniversary?.id ?? 0, user: anniversary?.user ?? 1, description: description, date: dateString)
                    onAddAnniversary(newAnniversary)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationTitle(anniversary == nil ? "Add Anniversary" : "Edit Anniversary")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .onAppear {
            if let anniversary = anniversary {
                description = anniversary.description
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                if let date = formatter.date(from: anniversary.date) {
                    self.date = date
                }
            }
        }
    }
}
 */

struct Anniversary: Identifiable, Codable {
    var id: Int
    var user: Int
    var description: String
    var date: String // Use Date type if preferred
}


struct AnniversaryListView_Previews: PreviewProvider {
    static var previews: some View {
        AnniversaryListView()
    }
}
