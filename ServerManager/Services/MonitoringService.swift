import Foundation

struct MonitoringService {
    static let shared = MonitoringService()
    private init() {}
    
    private struct AltertsResponse: Decodable {
        let alerts: [AlertInfo]
    }
    
    private struct LogsResponse: Decodable {
        let logs: [LogEntry]
    }




    /// Fetches the list of services from your API and maps into `ServiceInfo`
    func fetchServices() async throws -> [ServiceInfo] {
        let url = URL(string: "https://rest.dextron04.in/api/services")!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        print("Fetching services..")

        let resp = try JSONDecoder().decode(ServicesResponse.self, from: data)
        
//        if let str = String(data: data, encoding: .utf8) {
//            print("📥 Raw JSON (Services):\n\(str)")
//        }
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
    
    func fetchSystemAlerts() async throws -> [AlertInfo] {
        let url = URL(string: "https://rest.dextron04.in/api/system-alerts")!
            let (data, _) = try await URLSession.shared.data(from: url)
        
//        if let raw = String(data: data, encoding: .utf8) {
//          print("🔴 Raw alerts response:\n\(raw)")
//        }

            // 1️⃣ Create an ISO8601 formatter that accepts fractional seconds
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [
                .withInternetDateTime,
                .withFractionalSeconds
            ]

            // 2️⃣ Set up your decoder with a custom date strategy
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .custom { decoder -> Date in
                let container = try decoder.singleValueContainer()
                let str = try container.decode(String.self)
                if let date = isoFormatter.date(from: str) {
                    return date
                }
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid ISO8601 date: \(str)"
                )
            }

            // 3️⃣ Decode and return
            struct AlertsResponse: Decodable { let alerts: [AlertInfo] }
            let resp = try decoder.decode(AlertsResponse.self, from: data)
            return resp.alerts
    }
    
    func fetchLogs(serverName: String) async throws -> [LogEntry] {
        let url: URL = {
            switch serverName {
            case "Dex Pi 2":
                return URL(string: "https://rest.dextron04.in/raspi2/logs")!
            case "Dex Pi 4B":
                return URL(string: "https://rest.dextron04.in/raspi4b/logs")!
            default:
                return URL(string: "https://rest.dextron04.in/api/logs")!
            }
        }()
            let (data, _) = try await URLSession.shared.data(from: url)
            if let raw = String(data: data, encoding: .utf8) {
              print("🔴 Raw alerts response:\n\(raw)")
            }
            

            // ISO8601 with fractional seconds
            let iso = ISO8601DateFormatter()
            iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let str = try container.decode(String.self)
                if let d = iso.date(from: str) { return d }
                throw DecodingError.dataCorruptedError(in: container,
                  debugDescription: "Invalid date: \(str)")
            }

            return try decoder.decode(LogsResponse.self, from: data).logs
        }
}
