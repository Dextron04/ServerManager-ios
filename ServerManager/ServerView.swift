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

struct AlertMessage: Identifiable {
    let id = UUID()
    let text: String
}

// MARK: - Server Detail View
struct ServerDetailView: View {
    let server: Server
    @State private var stats: ServerStats?
    @State private var isStatsLoading = true
    @State private var statsError: String?
    
    @State private var isShowingLogs = false
    @State private var isShowingSSH = false
    @State private var isRestarting = false
    
    @State private var showingPasswordPrompt = false
    @State private var passwordInput = ""
    @State private var restartMessage: String? = nil
    @State private var showRestartResult = false
    @State private var showConfirmRestart = false
    @State private var alertMessage: AlertMessage?
    
    var body: some View {
        ScrollView {
                   VStack(spacing: 20) {
                       // Header
                       ServerHeaderView(server: server)
                       
                       // Quick Actions
                       QuickActionsView(
                           onRestart: {showingPasswordPrompt = true},
                           isShowingSSH: $isShowingSSH,
                           isShowingLogs: $isShowingLogs
                       )
                       
                       // ■ conditional Resources card
                       if isStatsLoading {
                           ProgressView("Loading stats…")
                               .frame(maxWidth: .infinity)
                       }
                       else if let err = statsError {
                           Text(err)
                               .foregroundColor(.red)
                               .multilineTextAlignment(.center)
                               .padding()
                       }
                       else if let stats {
                           // pass real stats into the card
                           ResourcesCardView(stats: stats)
                       }
                       
                       if let msg = restartMessage {
                           Text(msg)
                               .foregroundColor(.secondary)
                               .padding(.top)
                       }
                       
                       // Server Information
                       InformationCardView(server: server)
                   }
                   .padding()
               }
               .navigationTitle(server.name)
        
               .alert("Restart Server?",
                      isPresented: $showConfirmRestart
               ) {
                   Button("Cancel", role: .cancel) { }
                   Button("Confirm", role: .destructive) {
                       showingPasswordPrompt = true
                   }
               } message: {
                   Text("Are you sure you want to restart \(server.name)?")
               }
        
               .sheet(isPresented: $showingPasswordPrompt) {
                   VStack(spacing: 16) {
                       Text("Enter Admin Password")
                           .font(.headline)
                       SecureField("Password", text: $passwordInput)
                           .textFieldStyle(.roundedBorder)
                           .padding(.horizontal)
                       
                       HStack {
                           Button("Cancel") {
                               showingPasswordPrompt = false
                               passwordInput = ""
                           }
                           Spacer()
                           Button("Confirm") {
                               restartServer()
                           }
                           .disabled(passwordInput.isEmpty)
                       }
                       .padding()
                   }
                   .presentationDetents([.fraction(0.25)])
               }
        
               .alert(item: $alertMessage) { alert in
                   Alert(
                       title: Text("Restart Result"),
                       message: Text(alert.text),
                       dismissButton: .default(Text("OK")) {
                           // nothing more needed—alertMessage goes back to nil automatically
                       }
                   )
               }
               .navigationBarTitleDisplayMode(.large)
        .task {
            await loadStats()
        }
        .refreshable {
          Task.detached {
            await loadStats()
          }
        }
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
//        .alert("Restarting Server", isPresented: $isRestarting) {
//            Button("Cancel", role: .cancel) { isRestarting = false }
//            Button("Confirm", role: .destructive) {
//                // Implement restart logic here
//                isRestarting = false
//            }
//        } message: {
//            Text("Are you sure you want to restart \(server.name)?")
//        }
        .sheet(isPresented: $isShowingSSH) {
            SSHConnectionView(server: server)
        }
        .sheet(isPresented: $isShowingLogs) {
            ServerLogsView(server: server)
        }
    }
    
    private func loadStats() async {
        isStatsLoading = true
        defer { isStatsLoading = false }

        do {
            let fetched = try await ServerStatsService.shared
                .fetchStats(serverName: server.name)
            stats = fetched
        }
        catch is CancellationError {
            print("🔄 loadStats was cancelled")
        }
        catch {
            statsError = error.localizedDescription
        }
    }
    
    private func restartServer() {
        showingPasswordPrompt = false
        isRestarting = true
        Task {
            do {
                let resp = try await ServerCommandService.shared
                    .restartServer(serverName: server.name,
                                   password: passwordInput)
                alertMessage = AlertMessage(text: resp.message)
            } catch {
                alertMessage = AlertMessage(text: "Error: \(error.localizedDescription)")
            }
            showRestartResult = true
            passwordInput = ""
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
    let onRestart: () -> Void
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
                    onRestart()
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
    
    func restart() {
        
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
    // Old: let cpuUsage = 45, etc.
    let stats: ServerStats

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resources")
                .font(.headline)
                .padding(.leading, 8)
            
            VStack(spacing: 16) {
                ResourceGraphViews(
                  title: "CPU Load (1m)",
                  value: stats.cpu.loadavg1min,
                  icon: "cpu"
                )
                ResourceGraphViews(
                  title: "CPU Load (5m)",
                  value: stats.cpu.loadavg5min,
                  icon: "cpu"
                )
                ResourceGraphViews(
                  title: "CPU Load (15m)",
                  value: stats.cpu.loadavg15min,
                  icon: "cpu"
                )
                
                ResourceGraphViews(
                  title: "Memory Usage",
                  value: Double(stats.memory.usagePercent) ?? 0,
                  icon: "memorychip"
                )
                
                ResourceGraphViews(
                  title: "Disk Usage",
                  value: Double(
                    stats.disk.usePercent
                      .trimmingCharacters(in: CharacterSet(charactersIn: "%"))
                  ) ?? 0,
                  icon: "internaldrive"
                )
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
    let value: Double
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.subheadline)
                    Spacer()
                    Text("\(String(format: "%.1f", value))%")
                        .font(.subheadline.bold())
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(self.barColor)
                            .frame(
                              width: geo.size.width * CGFloat(min(value, 100) / 100),
                              height: 8
                            )
                    }
                }
                .frame(height: 8)
            }
        }
    }
    
    private var barColor: Color {
        switch value {
        case 0..<60:  return .green
        case 60..<80: return .orange
        default:      return .red
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

    @State private var logFilter: String = "All"
    @State private var logs: [LogEntry] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    let logOptions = ["All"] + LogEntry.LogLevel.allCases.map { $0.rawValue }

    var filtered: [LogEntry] {
        guard logFilter != "All", let lvl = LogEntry.LogLevel(rawValue: logFilter) else {
            return logs
        }
        return logs.filter { $0.level == lvl }
    }

    var body: some View {
        NavigationView {
            VStack {
                Picker("Filter", selection: $logFilter) {
                    ForEach(logOptions, id: \.self) { Text($0) }
                }
                .pickerStyle(.segmented)
                .padding()

                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else if let err = errorMessage {
                    Text(err)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                else if filtered.isEmpty {
                    Text("No logs")
                        .foregroundColor(.secondary)
                        .padding()
                }
                else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(filtered) { entry in
                                LogRow(entry: entry)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Server Logs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { presentationMode.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { Task { await loadLogs() } } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .refreshable { await loadLogs() }
            .task { await loadLogs() }
        }
    }

    private func loadLogs() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            logs = try await MonitoringService.shared
                .fetchLogs(serverName: server.name)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct LogRow: View {
    let entry: LogEntry

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(entry.level.color)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.message)
                    .font(.body)

                HStack(spacing: 6) {
                    Text(entry.level.rawValue)
                        .font(.caption)
                        .foregroundColor(entry.level.color)

                    Text("·")

                    Text(RelativeDateTimeFormatter()
                        .localizedString(for: entry.timestamp, relativeTo: Date()))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
