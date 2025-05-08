//
//  SettingsView.swift
//  ServerManager
//
//  Created by Tushin Kulshreshtha on 5/7/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var notifications = true
    @State private var darkMode = false
    @State private var refreshInterval = 5.0
    
    var body: some View {
        Form {
            Section(header: Text("Preferences")) {
                Toggle("Enable Notifications", isOn: $notifications)
                Toggle("Dark Mode", isOn: $darkMode)
            }
            
            Section(header: Text("Monitoring")) {
                VStack(alignment: .leading) {
                    Text("Refresh Interval")
                    Slider(value: $refreshInterval, in: 1...30, step: 1) {
                        Text("Refresh Interval")
                    }
                    Text("\(Int(refreshInterval)) seconds")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Section(header: Text("Account")) {
                Button("Sign Out") {
                    // Handle sign out
                }
                .foregroundColor(.red)
            }
        }
    }
}
