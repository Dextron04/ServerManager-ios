import SwiftUI

struct MonitoringView: View {
    @State private var services: [ServiceInfo] = []
    @State private var alerts: [AlertInfo] = []
    @State private var isLoadingServices = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("System Overview")) {
                    SystemOverviewRow(cpuUsage: 58, memoryUsage: 75, diskUsage: 42)
                }
                
                Section(header: Text("Active Services")) {
                    if isLoadingServices {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    else if services.isEmpty {
                        Text("No active services")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    else {
                        ForEach(services) { service in
                            ServiceRowView(service: service)
                        }
                    }
                }
                
                Section(header: Text("Alerts")) {
                    if alerts.isEmpty {
                        Text("No active alerts")
                            .font(.subheadline)
                            .foregroundColor(.gray)
//                            .padding(.vertical, 4)
                    } else {
                        ForEach(alerts) { alert in
                            AlertRowView(alert: alert)
                        }
                    }
                }
            }
            .navigationTitle("Server Monitor")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await loadServices()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .refreshable {
                await loadServices()
                await loadAlerts()
            }
            .task {
                await loadServices()
                await loadAlerts()
            }
        }
    }
    
    private func loadServices() async {
        isLoadingServices = true
        defer {isLoadingServices = false}
        do {
            services = try await MonitoringService.shared.fetchServices()
        } catch {
            print("Failed to load services: \(error)")
        }
    }
    
    private func loadAlerts() async {
        do {
            alerts = try await MonitoringService.shared.fetchSystemAlerts()
        } catch {
            print("Failed to load alerts: \(error)")
        }
    }
}

struct SystemOverviewRow: View {
    let cpuUsage: Double
    let memoryUsage: Double
    let diskUsage: Double
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                SystemMetricView(
                    icon: "cpu",
                    title: "CPU",
                    value: cpuUsage,
                    valueText: "\(Int(cpuUsage))%",
                    color: cpuUsage > 80 ? .red : .blue
                )
                
                Divider()
                
                SystemMetricView(
                    icon: "memorychip",
                    title: "Memory",
                    value: memoryUsage,
                    valueText: "\(Int(memoryUsage))%",
                    color: memoryUsage > 80 ? .red : .blue
                )
                
                Divider()
                
                SystemMetricView(
                    icon: "internaldrive",
                    title: "Disk",
                    value: diskUsage,
                    valueText: "\(Int(diskUsage))%",
                    color: diskUsage > 80 ? .red : .green
                )
            }
        }
//        .padding(.vertical, 8)
    }
}

struct SystemMetricView: View {
    let icon: String
    let title: String
    let value: Double
    let valueText: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
            }

            Text(valueText)
                .font(.headline)
                .padding(.top, 2)
                
            ProgressView(value: value, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .frame(width: 80)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ServiceInfo: Identifiable {
    let id = UUID()
    let name: String
    let status: ServiceStatus
    let description: String
    let uptime: String
    
    enum ServiceStatus: String {
        case running = "Running"
        case stopped = "Stopped"
        case warning = "Warning"
        
        var color: Color {
            switch self {
            case .running: return .green
            case .stopped: return .red
            case .warning: return .orange
            }
        }
    }
}

struct ServiceRowView: View {
    let service: ServiceInfo
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(service.name)
                        .font(.headline)
                    
                    Text(service.status.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(service.status.color.opacity(0.2))
                        .foregroundColor(service.status.color)
                        .cornerRadius(4)
                }
                
                Text(service.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("Uptime: \(service.uptime)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

struct AlertInfo: Identifiable, Decodable {
    let id: String                  // ← use the API’s UUID
    let title: String
    let description: String
    let severity: AlertSeverity
    let timestamp: Date

    enum AlertSeverity: String, Decodable {
        case high   = "High"
        case medium = "Medium"
        case low    = "Low"

        var color: Color {
            switch self {
            case .high:   return .red
            case .medium: return .orange
            case .low:    return .blue
            }
        }
    }

    // map JSON keys if needed (here they match)
    private enum CodingKeys: String, CodingKey {
        case id, title, description, severity, timestamp
    }
}

struct AlertRowView: View {
    let alert: AlertInfo
    
    var body: some View {
        HStack {
            Circle()
                .fill(alert.severity.color)
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(alert.title)
                    .font(.headline)
                
                Text(alert.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Text(alert.severity.rawValue)
                        .font(.caption)
                        .foregroundColor(alert.severity.color)
                    
                    Text("Â·")
                    
                    Text(formattedTime(alert.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    

}

//struct MonitoringView_Previews: PreviewProvider {
//    static var previews: some View {
//        MonitoringView()
//    }
//}
