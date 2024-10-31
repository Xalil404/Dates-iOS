//
//  Untitled.swift
//  Dates
//
//  Created by TEST on 31.10.2024.
//
import Foundation

struct UserAnniversary: Identifiable, Codable {
    var id: Int                // Unique identifier for the anniversary
    var user: Int              // User ID associated with the anniversary
    var description: String     // Description of the anniversary (e.g., event name)
    var date: Date             // Date of the anniversary as a Date type
}

