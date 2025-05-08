//
//  ContentView.swift
//  ServerManager
//
//  Created by Tushin Kulshreshtha on 1/28/25.
//

import SwiftUI

struct ContentView: View {
    @State private var servers: [Server] = [
        Server(name: "Production Server", status: .online, ipAddress: "192.168.1.1", uptime: "15d 4h"),
        Server(name: "Development Server", status: .maintenance, ipAddress: "192.168.1.2", uptime: "2d 6h"),
        Server(name: "Backup Server", status: .offline, ipAddress: "192.168.1.3", uptime: "0d 0h")
    ]
    
    @State private var animateSplash = false
    
    @State private var selectedTab = 0
    @State private var showingAddServer = false
    @State private var showSplash: Bool = true
    
    var body: some View {
        ZStack {
            // Your real app UI
            mainTabView
                .opacity(showSplash ? 0 : 1)
            
            // Splash overlay
            if showSplash {
                SplashView(isPresented: $showSplash)
            }
        }
    }
    
    private var mainTabView: some View {
        TabView {
            // Servers List Tab
            NavigationView {
                List {
                    ForEach(servers) { server in
                        ServerRowView(server: server)
                    }
                }
                .navigationTitle("Servers")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { showingAddServer.toggle() } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .tabItem {
                Image(systemName: "server.rack")
                Text("Servers")
            }
            .tag(0)
            
            // Monitoring Tab
            NavigationView {
                MonitoringView()
                    .navigationTitle("Monitoring")
            }
            .tabItem {
                Image(systemName: "chart.line.uptrend.xyaxis")
                Text("Monitoring")
            }
            .tag(1)
            
            // Settings Tab
            NavigationView {
                SettingsView()
                    .navigationTitle("Settings")
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
            .tag(2)
        }
    }
}


#Preview {
    ContentView()
}
