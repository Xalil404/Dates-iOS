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
            ZStack(alignment: .bottom) {
                // Set the background color to match the anniversaries screen
                Color(red: 248/255, green: 247/255, blue: 245/255)
                    .edgesIgnoringSafeArea(.all) // Fill the entire screen
                
                // Check if the list is empty
                if holidays.isEmpty {
                    // Empty state UI
                    VStack {
                        Image("emptyState")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                            .foregroundColor(.white)
                        
                        Text("No Holidays Yet")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.top, 10)
                        
                        Text("Add your first holiday to keep track of important dates.")
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 5)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Stacked floating bars for each holiday
                    ScrollView {
                        VStack(spacing: 20) {  // Space between each card
                            ForEach(holidays) { holiday in
                                VStack {
                                    HStack {
                                        // Circular ellipsis button with menu for edit and delete
                                        Menu {
                                            Button("Edit") {
                                                holidayToEdit = holiday
                                                showAddHoliday.toggle()
                                            }
                                            Button(role: .destructive) {
                                                if let index = holidays.firstIndex(where: { $0.id == holiday.id }) {
                                                    deleteHoliday(at: IndexSet(integer: index))
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
                                        Text(holiday.description.prefix(20) + (holiday.description.count > 20 ? "..." : ""))
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                        
                                        Spacer()
                                        
                                        Text("Date: \(holiday.month)/\(holiday.day)")
                                            .font(.subheadline)
                                            .foregroundColor(.black.opacity(0.7))
                                            .fontWeight(.bold)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 75) // Set consistent height
                                    .background(Color(red: 135/255, green: 206/255, blue: 235/255)) // Sky Blue card color
                                    .cornerRadius(12)
                                    .shadow(radius: 5)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
                
                // Add Holiday button
                Button(action: {
                    holidayToEdit = nil // Reset for adding a new holiday
                    showAddHoliday.toggle()
                }) {
                    Text("Add Holiday")
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
            //.navigationTitle("Holidays")
            //.navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Holidays")
                        .font(.headline) // Customize the font as needed
                        .foregroundColor(.black) // Ensure the text is black in all modes
                }
            }

            .sheet(isPresented: $showAddHoliday) {
                if let selectedHoliday = holidayToEdit {
                    AddHolidayView(onAddHoliday: { updatedHoliday in
                        updateHoliday(holiday: updatedHoliday)
                    }, holiday: selectedHoliday)
                } else {
                    AddHolidayView(onAddHoliday: { newHoliday in
                        addHoliday(holiday: newHoliday)
                    })
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
    
   
    /* Add & edit Holiday modal */
    
    struct AddHolidayView: View {
        @Environment(\.presentationMode) var presentationMode
        @State private var description: String = ""
        @State private var month: Int = 1 // Default month
        @State private var day: Int = 1 // Default day
        var onAddHoliday: (UserHoliday) -> Void
        var holiday: UserHoliday?
        
        @Environment(\.colorScheme) var colorScheme

        var body: some View {
            ZStack {
                Color(red: 135/255, green: 206/255, blue: 235/255) // Modal background color
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Text(holiday == nil ? "Add Holiday" : "Edit Holiday") // Dynamic title
                        .font(.largeTitle)
                        .foregroundColor(.white)

                    // Input field for holiday description
                    TextField("What is the special day?", text: $description)
                        .padding()
                        //.background(Color.white)
                        .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                        .cornerRadius(8)
                        //.foregroundColor(.black)
                        .foregroundColor(colorScheme == .dark ? .white : .black)

                    // HStack for Month and Day Pickers
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Month") // Label for Month Picker
                                .font(.headline)
                                .foregroundColor(.white)
                            Picker("Month", selection: $month) {
                                ForEach(1..<13) { month in
                                    Text("\(month)").tag(month)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color.white) // Ensuring the Picker is clickable
                            .cornerRadius(8)
                        }
                        .padding(.trailing) // Space between pickers

                        VStack(alignment: .leading) {
                            Text("Day") // Label for Day Picker
                                .font(.headline)
                                .foregroundColor(.white)
                            Picker("Day", selection: $day) {
                                ForEach(1..<32) { day in
                                    Text("\(day)").tag(day)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color.white) // Ensuring the Picker is clickable
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)

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

                        // Add/Update Holiday Button
                        Button(action: {
                            let newHoliday = UserHoliday(id: holiday?.id ?? 0, user: holiday?.user ?? 1, description: description, month: month, day: day)
                            onAddHoliday(newHoliday) // Trigger the callback
                            presentationMode.wrappedValue.dismiss() // Dismiss the modal after adding/updating
                        }) {
                            Text(holiday == nil ? "Add Holiday" : "Update Holiday")
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
                // Populate the fields if editing an existing holiday
                if let holiday = holiday {
                    description = holiday.description
                    month = holiday.month
                    day = holiday.day
                }
            }
        }
    }


    /* Ui is above; below are the functions */
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
/* Original add & edit holiday modal
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
*/

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
