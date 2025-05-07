//
//  ContentView.swift
//  ServerManager
//
//  Created by Tushin Kulshreshtha on 1/28/25.
//

import SwiftUI

struct Server: Identifiable {
    let id = UUID()
    let name: String
    let status: ServerStatus
    let ipAddress: String
    let uptime: String
}

enum ServerStatus: String {
    case online = "Online"
    case offline = "Offline"
    case maintenance = "Maintenance"
}

struct ContentView: View {
    @State private var servers: [Server] = [
        Server(name: "Production Server", status: .online, ipAddress: "192.168.1.1", uptime: "15d 4h"),
        Server(name: "Development Server", status: .maintenance, ipAddress: "192.168.1.2", uptime: "2d 6h"),
        Server(name: "Backup Server", status: .offline, ipAddress: "192.168.1.3", uptime: "0d 0h")
    ]
    
    @State private var animateSplash = false
    
    @State private var selectedTab = 0
    @State private var showingAddServer = false
    
    var body: some View {
        ZStack {
            // Your real app UI
            mainTabView
                .opacity(showSplash ? 0 : 1)
            
            // Splash overlay
            if showSplash {
                ZStack {
                    // Background color that fades in/out
                    Color.primary.opacity(0.05)
                        .edgesIgnoringSafeArea(.all)
                        .opacity(backgroundOpacity)
                    
                    VStack(spacing: 20) {
                        // Icon with multiple animations
                        Image(systemName: "server.rack.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.accentColor)
                            .scaleEffect(iconScale)
                            .rotationEffect(Angle(degrees: iconRotation))
                            .opacity(iconOpacity)
                            .shadow(color: .accentColor.opacity(0.5), radius: iconGlow ? 10 : 0)
                        
                        // App name with typing effect
                        Text("Dex Web")
                            .font(.largeTitle.bold())
                            .opacity(textOpacity)
                            .offset(y: textOffset)
                        
                        // Optional tagline
                        Text("Monitor Servers Like a Pro")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .opacity(taglineOpacity)
                    }
                    .padding()
                }
                .onAppear {
                    startSplashAnimationSequence()
                }
            }
        }
        .onAppear {
            // Initialize animation state
            resetAnimationState()
        }
    }

    // MARK: - Animation Properties
    @State private var showSplash = true
    @State private var iconScale: CGFloat = 0.2
    @State private var iconRotation: Double = -30
    @State private var iconOpacity: Double = 0
    @State private var iconGlow: Bool = false
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 10
    @State private var taglineOpacity: Double = 0
    @State private var backgroundOpacity: Double = 0

    // MARK: - Animation Functions
    private func resetAnimationState() {
        showSplash = true
        iconScale = 0.2
        iconRotation = -30
        iconOpacity = 0
        iconGlow = false
        textOpacity = 0
        textOffset = 10
        taglineOpacity = 0
        backgroundOpacity = 0
    }

    private func startSplashAnimationSequence() {
        // Stage 1: Fade in background
        withAnimation(.easeIn(duration: 0.3)) {
            backgroundOpacity = 1.0
        }
        
        // Stage 2: Animate icon in with bounce effect
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0.6).delay(0.2)) {
            iconScale = 1.0
            iconRotation = 0
            iconOpacity = 1.0
        }
        
        // Stage 3: Add glow effect to icon
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.4)) {
                iconGlow = true
            }
        }
        
        // Stage 4: Slide in and fade in the text
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                textOpacity = 1.0
                textOffset = 0
            }
        }
        
        // Stage 5: Fade in the tagline
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.easeOut(duration: 0.5)) {
                taglineOpacity = 1.0
            }
        }
        
        // Stage 6: Short pause to appreciate the animation
        
        // Stage 7: Fade out the entire splash screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeIn(duration: 0.6)) {
                showSplash = false
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

struct ServerRowView: View {
    let server: Server
    
    var body: some View {
        NavigationLink(destination: ServerDetailView(server: server)) {
            HStack {
                VStack(alignment: .leading) {
                    Text(server.name)
                        .font(.headline)
                    Text(server.ipAddress)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                StatusBadgeView(status: server.status)
            }
            .padding(.vertical, 4)
        }
    }
}

struct StatusBadgeView: View {
    let status: ServerStatus
    
    var statusColor: Color {
        switch status {
        case .online: return .green
        case .offline: return .red
        case .maintenance: return .orange
        }
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            Text(status.rawValue)
                .font(.caption)
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ServerDetailView: View {
    let server: Server
    
    var body: some View {
        List {
            Section(header: Text("Server Information")) {
                DetailRowView(title: "Name", value: server.name)
                DetailRowView(title: "IP Address", value: server.ipAddress)
                DetailRowView(title: "Status", value: server.status.rawValue)
                DetailRowView(title: "Uptime", value: server.uptime)
            }
            
            Section(header: Text("Actions")) {
                Button(action: {}) {
                    Label("Restart Server", systemImage: "arrow.clockwise")
                }
                Button(action: {}) {
                    Label("SSH Connection", systemImage: "terminal")
                }
                Button(action: {}) {
                    Label("View Logs", systemImage: "doc.text")
                }
            }
            
            Section(header: Text("Resources")) {
                ResourceGraphView(title: "CPU Usage", value: 45)
                ResourceGraphView(title: "Memory Usage", value: 68)
                ResourceGraphView(title: "Disk Usage", value: 72)
            }
        }
        .navigationTitle(server.name)
    }
}

struct DetailRowView: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
        }
    }
}

struct ResourceGraphView: View {
    let title: String
    let value: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack {
                Text("\(Int(value))%")
                    .font(.headline)
                
                ProgressView(value: value, total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: value > 80 ? .red : .blue))
            }
        }
    }
}

struct MonitoringView: View {
    var body: some View {
        List {
            Section(header: Text("System Overview")) {
                ResourceGraphView(title: "Total CPU Usage", value: 58)
                ResourceGraphView(title: "Total Memory Usage", value: 75)
                ResourceGraphView(title: "Network Traffic", value: 42)
            }
            
            Section(header: Text("Alerts")) {
                AlertRowView(title: "High CPU Usage", description: "Server 1 CPU usage above 90%", severity: .high)
                AlertRowView(title: "Memory Warning", description: "Low memory on Development Server", severity: .medium)
            }
        }
    }
}

struct AlertRowView: View {
    let title: String
    let description: String
    let severity: AlertSeverity
    
    enum AlertSeverity {
        case high, medium, low
        
        var color: Color {
            switch self {
            case .high: return .red
            case .medium: return .orange
            case .low: return .blue
            }
        }
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(severity.color)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

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
#Preview {
    ContentView()
}
