//
//  ServerView.swift
//  ServerManager
//
//  Created by Tushin Kulshreshtha on 5/7/25.
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
