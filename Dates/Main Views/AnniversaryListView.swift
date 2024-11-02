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
                    .background(Color(red: 248/255, green: 247/255, blue: 245/255))
                    .edgesIgnoringSafeArea(.all)
                } else {
                    // List of anniversaries
                    List {
                        ForEach(anniversaries) { anniversary in
                            VStack(alignment: .leading) {
                                Text(anniversary.description)
                                    .font(.headline)
                                Text("Date: \(anniversary.date)")
                                    .font(.subheadline)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    // Call deleteAnniversary with the anniversary ID
                                    if let index = anniversaries.firstIndex(where: { $0.id == anniversary.id }) {
                                        deleteAnniversary(at: IndexSet(integer: index))
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Button {
                                    // Handle edit anniversary here
                                    anniversaryToEdit = anniversary
                                    showAddAnniversary.toggle()
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                            }
                        }
                        .onDelete(perform: deleteAnniversary)
                    }
                    .listStyle(PlainListStyle())
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
        .background(Color.clear)
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
