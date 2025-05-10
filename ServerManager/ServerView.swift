import SwiftUI

struct Server: Identifiable {
    let id = UUID()
    let name: String
    let status: ServerStatus
    let ipAddress: String
}

enum ServerStatus: String {
    case online = "Online"
    case offline = "Offline"
}

// MARK: - Server List View
struct ServerListView: View {
    let servers: [Server]
    
    var body: some View {
        List {
            ForEach(servers) { server in
                ServerRowView(server: server)
            }
        }
        .navigationTitle("Servers")
        .listStyle(InsetGroupedListStyle())
        .refreshable {
            // You can add refresh logic here when you implement data fetching
        }
    }
}

struct ServerRowView: View {
    let server: Server
    
    var body: some View {
        NavigationLink(destination: ServerDetailView(server: server)) {
            HStack(spacing: 12) {
                // Icon representing server type
                Image(systemName: "server.rack")
                    .font(.system(size: 24))
                    .foregroundColor(.accentColor)
                    .frame(width: 36, height: 36)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(server.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Text(server.ipAddress)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                StatusBadgeView(status: server.status)
            }
            .padding(.vertical, 6)
        }
        .swipeActions(edge: .trailing) {
            Button(action: {}) {
                Label("Restart", systemImage: "arrow.clockwise")
            }
            .tint(.orange)
            
            Button(action: {}) {
                Label("SSH", systemImage: "terminal")
            }
            .tint(.blue)
        }
    }
}

struct StatusBadgeView: View {
    let status: ServerStatus
    
    var statusColor: Color {
        switch status {
        case .online: return .green
        case .offline: return .red
        }
    }
    
    var statusIcon: String {
        switch status {
        case .online: return "checkmark.circle.fill"
        case .offline: return "xmark.circle.fill"
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: statusIcon)
                .font(.caption)
            
            Text(status.rawValue)
                .font(.caption.bold())
        }
        .foregroundColor(statusColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(statusColor.opacity(0.15))
        )
    }
}

// MARK: - Server Detail View
struct ServerDetailView: View {
    let server: Server
    @State private var isShowingLogs = false
    @State private var isShowingSSH = false
    @State private var isRestarting = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                ServerHeaderView(server: server)
                
                // Quick Actions
                QuickActionsView(
                    isRestarting: $isRestarting,
                    isShowingSSH: $isShowingSSH,
                    isShowingLogs: $isShowingLogs
                )
                
                // Resources
                ResourcesCardView(server: server)
                
                // Server Information
                InformationCardView(server: server)
            }
            .padding()
        }
        .navigationTitle(server.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: {}) {
                        Label("Edit Server", systemImage: "pencil")
                    }
                    Button(action: {}) {
                        Label("Delete Server", systemImage: "trash")
                    }
                    Button(action: {}) {
                        Label("Share Details", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Restarting Server", isPresented: $isRestarting) {
            Button("Cancel", role: .cancel) { isRestarting = false }
            Button("Confirm", role: .destructive) {
                // Implement restart logic here
                isRestarting = false
            }
        } message: {
            Text("Are you sure you want to restart \(server.name)?")
        }
        .sheet(isPresented: $isShowingSSH) {
            SSHConnectionView(server: server)
        }
        .sheet(isPresented: $isShowingLogs) {
            ServerLogsView(server: server)
        }
    }
}

struct ServerHeaderView: View {
    let server: Server
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "server.rack")
                .font(.system(size: 50))
                .foregroundColor(.accentColor)
            
            VStack(spacing: 8) {
                Text(server.name)
                    .font(.title2.bold())
                
                StatusBadgeView(status: server.status)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

struct QuickActionsView: View {
    @Binding var isRestarting: Bool
    @Binding var isShowingSSH: Bool
    @Binding var isShowingLogs: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .padding(.leading, 8)
            
            HStack(spacing: 16) {
                ActionButtonView(
                    title: "Restart",
                    icon: "arrow.clockwise",
                    color: .orange
                ) {
                    isRestarting = true
                }
                
                ActionButtonView(
                    title: "SSH",
                    icon: "terminal",
                    color: .blue
                ) {
                    isShowingSSH = true
                }
                
                ActionButtonView(
                    title: "Logs",
                    icon: "doc.text",
                    color: .purple
                ) {
                    isShowingLogs = true
                }
                
                ActionButtonView(
                    title: "Configure",
                    icon: "gear",
                    color: .gray
                ) {
                    // Implement configuration action
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

struct ActionButtonView: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct ResourcesCardView: View {
    let server: Server
    // Using hard-coded values to avoid adding fake data
    let cpuUsage = 45
    let memoryUsage = 68
    let diskUsage = 72
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resources")
                .font(.headline)
                .padding(.leading, 8)
            
            VStack(spacing: 16) {
                ResourceGraphViews(title: "CPU Usage", value: cpuUsage, icon: "cpu", color: .blue)
                ResourceGraphViews(title: "Memory Usage", value: memoryUsage, icon: "memorychip", color: .green)
                ResourceGraphViews(title: "Disk Usage", value: diskUsage, icon: "internaldrive", color: .purple)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
    }
}

struct ResourceGraphViews: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(value)%")
                        .font(.subheadline.bold())
                        .foregroundColor(color)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(usageColor)
                            .frame(width: geometry.size.width * CGFloat(value) / 100, height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
    }
    
    var usageColor: Color {
        if value < 60 {
            return color
        } else if value < 80 {
            return .orange
        } else {
            return .red
        }
    }
}

struct InformationCardView: View {
    let server: Server
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Server Information")
                .font(.headline)
                .padding(.leading, 8)
            
            VStack(spacing: 0) {
                DetailRowView(icon: "server", title: "Name", value: server.name)
                
                Divider()
                    .padding(.leading, 48)
                
                DetailRowView(icon: "network", title: "IP Address", value: server.ipAddress)
                
                Divider()
                    .padding(.leading, 48)
                
                Divider()
                    .padding(.leading, 48)
                
                DetailRowView(icon: "info.circle", title: "Status", value: server.status.rawValue, valueColor: statusColor(status: server.status))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
    }
    
    func statusColor(status: ServerStatus) -> Color {
        switch status {
        case .online: return .green
        case .offline: return .red
        }
    }
}

struct DetailRowView: View {
    let icon: String
    let title: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(valueColor)
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Supporting Views
struct SSHConnectionView: View {
    let server: Server
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                // Your SSH terminal view implementation here
                // Placeholder for the SSH terminal interface
                VStack(spacing: 20) {
                    Image(systemName: "terminal")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    
                    Text("SSH Connection to \(server.name)")
                        .font(.headline)
                    
                    Text(server.ipAddress)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemBackground))
            }
            .navigationTitle("SSH Terminal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct ServerLogsView: View {
    let server: Server
    @Environment(\.presentationMode) var presentationMode
    @State private var logFilter = "All"
    
    let logOptions = ["All", "Error", "Warning", "Info"]
    
    var body: some View {
        NavigationView {
            VStack {
                // Log filtering options
                Picker("Filter", selection: $logFilter) {
                    ForEach(logOptions, id: \.self) { option in
                        Text(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Your logs implementation here
                // Placeholder for log entries
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Logs will appear here when connected to your server")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                    .padding()
                }
            }
            .navigationTitle("Server Logs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {}) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}
