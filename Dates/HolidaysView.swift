//
//  HolidaysView.swift
//  Dates
//
//  Created by TEST on 31.10.2024.
//

import SwiftUI

struct HolidaysView: View {
    var body: some View {
        VStack {
            Text("Holidays")
                .font(.largeTitle)
                .padding()
            Text("This is a placeholder for the Holidays screen.")
                .font(.subheadline)
                .padding()
        }
        .navigationTitle("Holidays")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HolidaysView_Previews: PreviewProvider {
    static var previews: some View {
        HolidaysView()
    }
}
