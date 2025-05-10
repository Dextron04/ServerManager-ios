//
//  ContentView.swift
//  ServerManager
//
//  Created by Tushin Kulshreshtha on 1/28/25.
//

import SwiftUI

struct ContentView: View {
//    @State private var servers: [Server] = [
//        Server(name: "Production Server", status: .online, ipAddress: "192.168.1.1"),
//        Server(name: "Development Server", status: .offline, ipAddress: "192.168.1.2"),
//        Server(name: "Backup Server", status: .offline, ipAddress: "192.168.1.3")
//    ]
    
    @State private var servers: [Server] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
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
                Group {
                    if isLoading && servers.isEmpty {
                        ProgressView()
                    } else if let err = errorMessage {
                        Text(err)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else {
                        List(servers) { server in
                            ServerRowView(server: server)
                        }
                        .listStyle(.insetGrouped)
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
                .refreshable {
                    Task.detached {
                        await MainActor.run { isLoading = true }
                        defer { Task { await MainActor.run { isLoading = false } } }

                        do {
                            let list = try await ServerService.shared.fetchServers()
                            await MainActor.run { servers = list }
                        } catch {
                            await MainActor.run { errorMessage = error.localizedDescription }
                        }
                    }
                }
                .task {
                    await loadServers()
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
    private func loadServers() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let list = try await ServerService.shared.fetchServers()
            servers = list
        }
        catch is CancellationError {
            // ❗️ This is expected if the refresh task was torn down—
            //     swallow it so you don’t show a “cancelled” error.
            print("🔄 loadServers was cancelled")
        }
        catch {
            // Only genuine networking/decoding errors land here
            errorMessage = error.localizedDescription
        }
    }
}





#Preview {
    ContentView()
}
