//
//  AppError.swift
//  Domain
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Foundation

public struct ResponseWrapper<Value: Decodable & Sendable>: Decodable, Sendable {
  let response: Value

  public var value: Value {
    response
  }
}

public enum AppError: Error, Identifiable, Sendable {

  public struct MiddlewareAPIError: Decodable, LocalizedError, Sendable {
    public struct Header: Decodable, Sendable {
      public let system_timestamp: Date
      public let api_ver: String
    }

    public let success: Bool
    public let message: String
    public let status_code: Int
    public let phoneID: String
    public let header: Header

    public var errorDescription: String? {
      message
    }
  }

  public struct WebsiteAPIError: Decodable, LocalizedError, Sendable {
    let error_code: String
    let status_code: Int
    let message: String
    public var errorDescription: String? {
      message
    }
  }

  public var id: String { localizedDescription }

  case databaseCorrupted(String?)
  case copyrightClaim(String)
  case middleWareAPIError(MiddlewareAPIError)
  case websiteAPIError(WebsiteAPIError)
  case networkingFailed(
    underlyingError: any Error, context: String, file: StaticString = #file,
    line: Int = #line)
  case httpStatus(code: Int)
  case unauthorized
  case parseFailed
  case noUpdates
  case notFound
  case unknown
}

extension AppError: Equatable {
  public static func == (lhs: AppError, rhs: AppError) -> Bool {
    lhs.id == rhs.id
  }
}

extension AppError: LocalizedError {
  var isRetryable: Bool {
    return false
  }

  public var errorDescription: String? {
    switch self {
    case .databaseCorrupted:
      return "Database Corrupted"
    case .copyrightClaim:
      return "Copyright Claim"
    case let .networkingFailed(underlying, context, file, line):
      return
        "Network Error:\nError Description: \(underlying)\nFile: \(file)\nLine: \(line)\nContext: \(context)"
    case let .middleWareAPIError(error):
      return error.localizedDescription
    case let .websiteAPIError(error):
      return error.localizedDescription
    case let .httpStatus(code):
      return "HTTP Error \(code)"
    case .unauthorized:
      return "Unauthorized"
    case .parseFailed:
      return "Parse Error"
    case .noUpdates:
      return "No updates available"
    case .notFound:
      return "Not found"
    case .unknown:
      return "Unknown Error"
    }
  }
}
