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

struct ServerStats: Decodable {
  let cpu: CPU
  let memory: Memory
  let disk: Disk

  struct CPU: Decodable {
    let loadavg1min: Double
    let loadavg5min: Double
    let loadavg15min: Double

    enum CodingKeys: String, CodingKey {
      case loadavg1min = "loadavg_1min"
      case loadavg5min = "loadavg_5min"
      case loadavg15min = "loadavg_15min"
    }
  }

  struct Memory: Decodable {
    let total: Int
    let free: Int
    let used: Int
    let usagePercent: String  // JSON has "usagePercent"
  }

  struct Disk: Decodable {
    let filesystem: String
    let size: String
    let used: String
    let available: String
    let usePercent: String   // JSON has "usePercent"
    let mount: String
  }
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
