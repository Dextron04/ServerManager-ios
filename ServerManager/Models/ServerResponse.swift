//
//  ServerResponse.swift
//  ServerManager
//
//  Created by Tushin Kulshreshtha on 5/9/25.
//
import Foundation
import SwiftUICore

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

struct CommandResponse: Decodable {
    let message: String
}

struct ServicesResponse: Decodable {
    let services: [ServiceData]
}

struct ServiceData: Decodable {
    let unit: String
    let load: String
    let active: String
    let sub: String
    let description: String
}

struct LogEntry: Identifiable, Decodable {
    let id: String
    let message: String
    let level: LogLevel
    let timestamp: Date

    enum LogLevel: String, Decodable, CaseIterable {
        case info   = "Info"
        case warning = "Warning"
        case error  = "Error"
        case other  = "Other"

        var color: Color {
            switch self {
            case .info:    return .blue
            case .warning: return .orange
            case .error:   return .red
            case .other:   return .gray
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id, message, level, timestamp
    }
}
