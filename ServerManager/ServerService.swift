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
        
        // 2. Fetch data
        let (data, _) = try await URLSession.shared.data(from: url)
        
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
