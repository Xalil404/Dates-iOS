//
//  MainTabView.swift
//  Dates
//
//  Created by TEST on 31.10.2024.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            BirthdayListView()
                .tabItem {
                    Label("Birthdays", systemImage: "gift")
                }
            
            AnniversaryListView()
                .tabItem {
                    Label("Anniversaries", systemImage: "heart")
                }
            
            HolidaysView()
                .tabItem {
                    Label("Holidays", systemImage: "calendar")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}


struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
