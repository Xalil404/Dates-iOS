//
//  UserHoliday.swift
//  Dates
//
//  Created by TEST on 31.10.2024.
//

import Foundation

struct UserHoliday: Identifiable, Codable {
    var id: Int                // Unique identifier for the anniversary
    var user: Int              // User ID associated with the anniversary
    var description: String     // Description of the anniversary (e.g., event name)
    var month: Int             // Month of the holiday (1-12)
    var day: Int               // Day of the holiday (1-31)
}

