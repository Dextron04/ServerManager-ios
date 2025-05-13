//
//  ServerService.swift
//  ServerManager
//
//  Created by Tushin Kulshreshtha on 5/9/25.
//

import Foundation

struct ServerService {
    static let shared = ServerService()
    let session: URLSession
    
    private init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    /// Fetch the servers list from your REST endpoint
    func fetchServers() async throws -> [Server] {
        // 1. Build URL (force-unwrap for brevity; you can guard it instead)
        let url = URL(string: "https://rest.dextron04.in/api/get-servers")!
        
        print("getting servers...")
        
        // 2. Fetch data
        let (data, res) = try await URLSession.shared.data(from: url)
        
        print("Server Fetched successfully! \(res)")
        
        // 3. Decode into your existing ServerResponse model
        let apiResponse = try JSONDecoder()
            .decode(ServerResponse.self, from: data)
        
        // 4. Map that dictionary into [Server] and return
        return apiResponse.servers.map { name, info in
            Server(
                name: name,
                status: ServerStatus(rawValue: info.status.capitalized) ?? .offline,
                ipAddress: info.ipAddress
            )
        }
    }
}

struct ServerStatsService {
    static let shared = ServerStatsService()
    let session: URLSession

    private init(session: URLSession = .shared) {
        self.session = session
    }

    /// Fetches stats for the server at the given IP.

    func fetchStats(serverName: String) async throws -> ServerStats {
        print("Server Name: \(serverName)")
        let url: URL = {
            switch serverName {
            case "Dex Pi 2":
                return URL(string: "https://rest.dextron04.in/raspi2/system-stats")!
            case "Dex Pi 4B":
                return URL(string: "https://rest.dextron04.in/raspi4b/system-stats")!
            default:
                return URL(string: "https://rest.dextron04.in/api/system-stats")!
            }
        }()
//        let url = URL(string: "https://rest.dextron04.in/api/system-stats")!
        let (data, _) = try await session.data(from: url)

        // Debug: print raw JSON once more
        if let str = String(data: data, encoding: .utf8) {
            print("📥 Raw JSON:\n\(str)")
        }

        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return try decoder.decode(ServerStats.self, from: data)
        }
        catch let decodingError as DecodingError {
            // Handle decoding issues explicitly
            switch decodingError {
            case .keyNotFound(let key, let context):
                print("❌ Missing key '\(key.stringValue)' at \(context.codingPath)")
            default:
                print("❌ DecodingError:", decodingError)
            }
            throw decodingError
        }
        catch let otherError {
            // Any other error (e.g. networking)
            print("❌ Unexpected error:", otherError)
            throw otherError
        }
    }
}

struct ServerCommandService {
    static let shared = ServerCommandService()
    let session: URLSession
    
    private init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct RestartRequest: Encodable {
        let password: String
    }
    
    func restartServer(serverName: String, password: String) async throws -> CommandResponse {
        print("Server Name is \(serverName)")
        let url: URL = {
            switch serverName {
            case "Dex Pi 2":
                return URL(string: "https://rest.dextron04.in/raspi2/restart")!
            case "Dex Pi 4B":
                return URL(string: "https://rest.dextron04.in/raspi4b/restart")!
            default:
                return URL(string: "https://rest.dextron04.in/api/restart")!
            }
        }()
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = RestartRequest(password: password)
        request.httpBody = try? JSONEncoder().encode(body)
        
        let (data, _) = try await session.data(for: request)
        
        do {
            let response = try JSONDecoder().decode(CommandResponse.self, from: data)
            if let str = String(data: data, encoding: .utf8) {
                print("📥 Raw JSON (Restart):\n\(str)")
            }
            return response
        } catch {
            throw URLError(.badServerResponse)
        }
    }
}
