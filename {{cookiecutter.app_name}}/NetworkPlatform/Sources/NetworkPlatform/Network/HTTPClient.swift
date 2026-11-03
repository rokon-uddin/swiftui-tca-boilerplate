//
//  HTTPClient.swift
//  NetworkPlatform
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Domain
import Foundation
import Utilities

/// The shared stream of request lifecycle events for every live `HTTPClient`.
enum NetworkActivityCenter {
  static let shared = AsyncBroadcaster<NetworkActivity>()
}

struct HTTPClient: Sendable {
  let transport: any HTTPTransport
  let activity: AsyncBroadcaster<NetworkActivity>?
  let tokenRefresher: TokenRefresher?

  init(
    transport: any HTTPTransport,
    activity: AsyncBroadcaster<NetworkActivity>? = nil,
    tokenRefresher: TokenRefresher? = nil
  ) {
    self.transport = transport
    self.activity = activity
    self.tokenRefresher = tokenRefresher
  }

  func request<T: Decodable & Sendable>(
    _ endpoint: some Endpoint,
    as _: T.Type = T.self
  ) async throws -> T {
    let data = try await data(for: endpoint)
    do {
      return try JSONDecoder().decode(T.self, from: data)
    } catch {
      Logger.error("Decoding \(T.self) failed: \(error)")
      throw AppError.parseFailed
    }
  }

  func data(for endpoint: some Endpoint, isRetry: Bool = false) async throws -> Data {
    var request = try endpoint.urlRequest()
    if endpoint.requiresAuth, let token = await tokenRefresher?.token {
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

    let id = UUID()
    await activity?.yield(.started(id: id, path: endpoint.path))
    Logger.info("Request: \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")

    let data: Data
    let response: HTTPURLResponse
    do {
      (data, response) = try await transport.send(request, stubFileName: endpoint.stubFileName)
    } catch {
      await activity?.yield(.failed(id: id, message: error.localizedDescription))
      Logger.error(error.localizedDescription)
      if error is AppError { throw error }
      throw AppError.networkingFailed(underlyingError: error, context: endpoint.path)
    }

    await activity?.yield(.finished(id: id, statusCode: response.statusCode))
    Logger.info("Status Code: \(response.statusCode)")

    switch response.status?.responseType {
    case .success:
      return data
    case .clientError where response.status == .unauthorized:
      guard !isRetry, let tokenRefresher else { throw AppError.unauthorized }
      try await tokenRefresher.refresh()
      return try await self.data(for: endpoint, isRetry: true)
    default:
      throw AppError.httpStatus(code: response.statusCode)
    }
  }
}
