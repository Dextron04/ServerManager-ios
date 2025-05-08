import SwiftUI

struct MonitoringView: View {
    @State private var services: [ServiceInfo] = sampleServices
    @State private var alerts: [AlertInfo] = sampleAlerts
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("System Overview")) {
                    SystemOverviewRow(cpuUsage: 58, memoryUsage: 75, diskUsage: 42)
                }
                
                Section(header: Text("Active Services")) {
                    ForEach(services) { service in
                        ServiceRowView(service: service)
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
                        refreshData()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .refreshable {
                refreshData()
            }
        }
    }
    
    private func refreshData() {
        isRefreshing = true
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            // In a real app, you would fetch actual data here
            services = sampleServices.shuffled()
            alerts = sampleAlerts.shuffled().prefix(Int.random(in: 1...3)).map { $0 }
            isRefreshing = false
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

struct AlertInfo: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let severity: AlertSeverity
    let timestamp: Date
    
    enum AlertSeverity: String {
        case high = "High"
        case medium = "Medium"
        case low = "Low"
        
        var color: Color {
            switch self {
            case .high: return .red
            case .medium: return .orange
            case .low: return .blue
            }
        }
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

// Sample data
let sampleServices: [ServiceInfo] = [
    ServiceInfo(name: "Nginx Server", status: .running, description: "Web server handling HTTP requests", uptime: "14 days, 3 hours"),
    ServiceInfo(name: "MySQL Database", status: .running, description: "Primary database server", uptime: "7 days, 12 hours"),
    ServiceInfo(name: "Redis Cache", status: .running, description: "In-memory data store", uptime: "14 days, 3 hours"),
    ServiceInfo(name: "Apache Kafka", status: .warning, description: "Stream-processing service", uptime: "2 days, 8 hours"),
    ServiceInfo(name: "Docker Engine", status: .running, description: "Container management", uptime: "5 days, 6 hours"),
    ServiceInfo(name: "ElasticSearch", status: .stopped, description: "Search and analytics engine", uptime: "0 minutes")
]

let sampleAlerts: [AlertInfo] = [
    AlertInfo(title: "High CPU Usage", description: "Server 1 CPU usage above 90%", severity: .high, timestamp: Date().addingTimeInterval(-1800)),
    AlertInfo(title: "Memory Warning", description: "Low memory on Development Server", severity: .medium, timestamp: Date().addingTimeInterval(-3600)),
    AlertInfo(title: "Disk Space", description: "Server 2 disk space below 10%", severity: .high, timestamp: Date().addingTimeInterval(-7200)),
    AlertInfo(title: "Service Restart", description: "Redis service restarted", severity: .low, timestamp: Date().addingTimeInterval(-14400))
]

//struct MonitoringView_Previews: PreviewProvider {
//    static var previews: some View {
//        MonitoringView()
//    }
//}
