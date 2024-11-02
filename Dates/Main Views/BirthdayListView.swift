//
//  BirthdayListView.swift
//  Dates
//
//  Created by TEST on 31.10.2024.
//
import SwiftUI

struct BirthdayListView: View {
    @State private var birthdays: [Birthday] = []
    @State private var showAddBirthday = false
    @State private var birthdayToEdit: Birthday? = nil
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // Check if the list is empty
                if birthdays.isEmpty {
                    // Empty state UI
                    VStack {
                        Image("emptyState")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                            .foregroundColor(.white)
                        
                        Text("No Birthdays Yet")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.top, 10)
                        
                        Text("Add your first birthday to remember special dates.")
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
                    // List of birthdays
                    List {
                        ForEach(birthdays) { birthday in
                            VStack(alignment: .leading) {
                                Text(birthday.description)
                                    .font(.headline)
                                Text("Date: \(birthday.date)")
                                    .font(.subheadline)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    // Call deleteBirthday with the birthday ID
                                    if let index = birthdays.firstIndex(where: { $0.id == birthday.id }) {
                                        deleteBirthday(at: IndexSet(integer: index))
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Button {
                                    // Handle edit birthday here
                                    birthdayToEdit = birthday
                                    showAddBirthday.toggle()
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                            }
                        }
                        .onDelete(perform: deleteBirthday)
                    }
                    .listStyle(PlainListStyle())
                }

                // Add Birthday button
                Button(action: {
                    birthdayToEdit = nil // Reset for adding a new birthday
                    showAddBirthday.toggle()
                }) {
                    Text("Add Birthday")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 232/255, green: 191/255, blue: 115/255)) // Update to match the anniversaries button color
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
                .shadow(radius: 5)
            }
            .navigationTitle("Birthdays")
            .navigationBarTitleDisplayMode(.inline)
            
            .sheet(isPresented: $showAddBirthday) {
                if let selectedBirthday = birthdayToEdit {
                    AddBirthdayView(onAddBirthday: { updatedBirthday in
                        updateBirthday(birthday: updatedBirthday)
                    }, birthday: selectedBirthday)
                } else {
                    AddBirthdayView(onAddBirthday: { newBirthday in
                        addBirthday(birthday: newBirthday)
                    })
                }
            }

            .onAppear {
                fetchBirthdays()
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

    func fetchBirthdays() {
        guard let token = UserDefaults.standard.string(forKey: "authToken"),
              let url = URL(string: "https://crud-backend-for-react-841cbc3a6949.herokuapp.com/api/birthdays/") else { return }

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
                let fetchedBirthdays = try JSONDecoder().decode([Birthday].self, from: data)
                DispatchQueue.main.async {
                    self.birthdays = fetchedBirthdays
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to decode data."
                }
            }
        }.resume()
    }

    func addBirthday(birthday: Birthday) {
        guard let token = UserDefaults.standard.string(forKey: "authToken"),
              let url = URL(string: "https://crud-backend-for-react-841cbc3a6949.herokuapp.com/api/birthdays/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = [
            "user": birthday.user,
            "description": birthday.description,
            "date": birthday.date
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
                fetchBirthdays() // Refresh the list after adding
            }
        }.resume()
    }

    func updateBirthday(birthday: Birthday) {
        guard let token = UserDefaults.standard.string(forKey: "authToken"),
              let url = URL(string: "https://crud-backend-for-react-841cbc3a6949.herokuapp.com/api/birthdays/\(birthday.id)/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT" // Use PUT for updates
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = [
            "user": birthday.user,
            "description": birthday.description,
            "date": birthday.date
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
                fetchBirthdays() // Refresh the list after updating
            }
        }.resume()
    }

    func deleteBirthday(at offsets: IndexSet) {
        for index in offsets {
            let birthdayId = birthdays[index].id
            guard let token = UserDefaults.standard.string(forKey: "authToken"),
                  let url = URL(string: "https://crud-backend-for-react-841cbc3a6949.herokuapp.com/api/birthdays/\(birthdayId)/") else { return }

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
                    self.birthdays.remove(at: index) // Remove from the array after deleting
                }
            }.resume()
        }
    }
}

struct AddBirthdayView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var description: String = ""
    @State private var date: Date = Date() // Change to Date type
    var onAddBirthday: (Birthday) -> Void
    var birthday: Birthday?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Birthday Details")) {
                    TextField("Description", text: $description)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                }

                Button(birthday == nil ? "Add Birthday" : "Update Birthday") {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    let dateString = formatter.string(from: date)
                    let newBirthday = Birthday(id: birthday?.id ?? 0, user: birthday?.user ?? 1, description: description, date: dateString)
                    onAddBirthday(newBirthday)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationTitle(birthday == nil ? "Add Birthday" : "Edit Birthday")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .onAppear {
            if let birthday = birthday {
                description = birthday.description
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                if let date = formatter.date(from: birthday.date) {
                    self.date = date
                }
            }
        }
    }
}

struct Birthday: Identifiable, Codable {
    var id: Int
    var user: Int
    var description: String
    var date: String // Use Date type if preferred
}



struct BirthdayListView_Previews: PreviewProvider {
    static var previews: some View {
        BirthdayListView()
    }
}
