//
//  HolidaysView.swift
//  Dates
//
//  Created by TEST on 31.10.2024.
//

//
//  HolidayListView.swift
//  Dates
//
//  Created by TEST on 31.10.2024.
//

import SwiftUI

struct HolidayListView: View {
    @State private var holidays: [UserHoliday] = []
    @State private var showAddHoliday = false
    @State private var holidayToEdit: UserHoliday? = nil
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(holidays) { holiday in
                        VStack(alignment: .leading) {
                            Text(holiday.description)
                                .font(.headline)
                            Text("Date: \(holiday.month)/\(holiday.day)")
                                .font(.subheadline)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                // Call deleteHoliday with the holiday ID
                                if let index = holidays.firstIndex(where: { $0.id == holiday.id }) {
                                    deleteHoliday(at: IndexSet(integer: index))
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                // Handle edit holiday here
                                holidayToEdit = holiday
                                showAddHoliday.toggle()
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }
                    }
                    .onDelete(perform: deleteHoliday)
                }
                
                Button(action: {
                    holidayToEdit = nil // Reset for adding a new holiday
                    showAddHoliday.toggle()
                }) {
                    Text("Add Holiday")
                        .fontWeight(.bold)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Holidays")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAddHoliday) {
                if let selectedHoliday = holidayToEdit {
                    AddHolidayView(holiday: selectedHoliday) { updatedHoliday in
                        updateHoliday(holiday: updatedHoliday)
                    }
                } else {
                    AddHolidayView { newHoliday in
                        addHoliday(holiday: newHoliday)
                    }
                }
            }
            .onAppear {
                fetchHolidays()
            }
            .alert(isPresented: Binding<Bool>(
                get: { !errorMessage.isEmpty },
                set: { if !$0 { errorMessage = "" }}
            )) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            
        }
    }

    func fetchHolidays() {
        guard let token = UserDefaults.standard.string(forKey: "authToken"),
              let url = URL(string: "https://crud-backend-for-react-841cbc3a6949.herokuapp.com/api/holidays/") else { return }

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
                let fetchedHolidays = try JSONDecoder().decode([UserHoliday].self, from: data)
                DispatchQueue.main.async {
                    self.holidays = fetchedHolidays
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to decode data."
                }
            }
        }.resume()
    }

    func addHoliday(holiday: UserHoliday) {
        guard let token = UserDefaults.standard.string(forKey: "authToken"),
              let url = URL(string: "https://crud-backend-for-react-841cbc3a6949.herokuapp.com/api/holidays/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = [
            "user": holiday.user,
            "description": holiday.description,
            "month": holiday.month,
            "day": holiday.day
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
                fetchHolidays() // Refresh the list after adding
            }
        }.resume()
    }

    func updateHoliday(holiday: UserHoliday) {
        guard let token = UserDefaults.standard.string(forKey: "authToken"),
              let url = URL(string: "https://crud-backend-for-react-841cbc3a6949.herokuapp.com/api/holidays/\(holiday.id)/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = [
            "user": holiday.user,
            "description": holiday.description,
            "month": holiday.month,
            "day": holiday.day
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
                fetchHolidays() // Refresh the list after updating
            }
        }.resume()
    }

    func deleteHoliday(at offsets: IndexSet) {
        for index in offsets {
            let holidayId = holidays[index].id
            guard let token = UserDefaults.standard.string(forKey: "authToken"),
                  let url = URL(string: "https://crud-backend-for-react-841cbc3a6949.herokuapp.com/api/holidays/\(holidayId)/") else { return }

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
                    self.holidays.remove(at: index) // Remove from the array after deleting
                }
            }.resume()
        }
    }
}

struct AddHolidayView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var description: String = ""
    @State private var month: Int = 1 // Default month
    @State private var day: Int = 1 // Default day
    var onAddHoliday: (UserHoliday) -> Void
    var holiday: UserHoliday?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Holiday Details")) {
                    TextField("Description", text: $description)
                    Picker("Month", selection: $month) {
                        ForEach(1..<13) { month in
                            Text("\(month)").tag(month)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    Picker("Day", selection: $day) {
                        ForEach(1..<32) { day in
                            Text("\(day)").tag(day)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                Button(holiday == nil ? "Add Holiday" : "Update Holiday") {
                    let newHoliday = UserHoliday(id: holiday?.id ?? 0, user: holiday?.user ?? 1, description: description, month: month, day: day)
                    onAddHoliday(newHoliday)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationTitle(holiday == nil ? "Add Holiday" : "Edit Holiday")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .onAppear {
            if let holiday = holiday {
                description = holiday.description
                month = holiday.month
                day = holiday.day
            }
        }
    }
}

struct Holiday: Identifiable, Codable {
    var id: Int
    var user: Int
    var description: String
    var month: Int
    var day: Int
}

struct HolidayListView_Previews: PreviewProvider {
    static var previews: some View {
        HolidayListView()
    }
}
