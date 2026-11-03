//
//  Endpoint.swift
//  NetworkPlatform
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Foundation

enum HTTPMethod: String, Sendable {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case patch = "PATCH"
  case delete = "DELETE"
}

/// Describes a single HTTP request. Conforming types are plain values, so they are
/// safe to pass across concurrency domains.
protocol Endpoint: Sendable {
  var baseURL: URL { get }
  var path: String { get }
  var method: HTTPMethod { get }
  var headers: [String: String] { get }
  var queryItems: [URLQueryItem] { get }
  var body: Data? { get }
  /// Name of a bundled JSON file (without extension) served by `StubTransport`.
  var stubFileName: String? { get }
  var requiresAuth: Bool { get }
}

extension Endpoint {
  var headers: [String: String] { [:] }
  var queryItems: [URLQueryItem] { [] }
  var body: Data? { nil }
  var stubFileName: String? { nil }
  var requiresAuth: Bool { false }

  func urlRequest() throws -> URLRequest {
    var components = URLComponents(
      url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
    if !queryItems.isEmpty {
      components?.queryItems = queryItems
    }
    guard let url = components?.url else {
      throw URLError(.badURL)
    }
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.httpBody = body
    request.httpShouldHandleCookies = false
    for (field, value) in headers {
      request.setValue(value, forHTTPHeaderField: field)
    }
    return request
  }
}
