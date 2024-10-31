//
//  Birthday.swift
//  Dates
//
//  Created by TEST on 31.10.2024.
//
import Foundation

struct UserBirthday: Identifiable, Codable {
    var id: Int                // Unique identifier for the birthday
    var user: Int              // User ID associated with the birthday
    var description: String     // Description of the birthday (e.g., person's name)
    var date: Date             // Date of the birthday as a Date type
}
