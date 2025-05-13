//
//  MonitoringService.swift
//  ServerManager
//
//  Created by Tushin Kulshreshtha on 5/10/25.
//

import Foundation

struct MonitoringService {
    static let shared = MonitoringService()
    private init() {}



    /// Fetches the list of services from your API and maps into `ServiceInfo`
    func fetchServices() async throws -> [ServiceInfo] {
        let url = URL(string: "https://rest.dextron04.in/api/services")!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        print("Fetching services..")

        let resp = try JSONDecoder().decode(ServicesResponse.self, from: data)
        
        if let str = String(data: data, encoding: .utf8) {
            print("📥 Raw JSON (Services):\n\(str)")
        }
        return resp.services.map { item in
            // pick a sensible display name
            let name = item.unit.isEmpty ? item.load : item.unit

            // decide status
            let status: ServiceInfo.ServiceStatus
            switch item.sub.lowercased() {
            case "active":
                status = .running
            case "exited":
                status = .warning
            default:
                status = .stopped
            }

            return ServiceInfo(
                name: name,
                status: status,
                description: item.description,
                uptime: ""
            )
        }
    }
}
