//
//  ServerResponse.swift
//  ServerManager
//
//  Created by Tushin Kulshreshtha on 5/9/25.
//
import Foundation

struct ServerResponse: Decodable {
    let servers: [String: ServerInfo]
}

struct ServerInfo: Decodable {
    let ipAddress: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case ipAddress = "ip_address"
        case status
    }
}

enum ServerServiceError: LocalizedError {
    case invalidURL
    case serverError(statusCode: Int)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:               return "Invalid server URL."
        case .serverError(let code):    return "Server returned status \(code)."
        case .decodingError(let err):   return "Data decoding error: \(err.localizedDescription)"
        }
    }
}
