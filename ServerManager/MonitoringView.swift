//
//  MonitoringView.swift
//  ServerManager
//
//  Created by Tushin Kulshreshtha on 5/7/25.
//

import SwiftUI

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
