//
//  TokenRefresher.swift
//  NetworkPlatform
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Foundation

/// Owns the access token and makes sure only one refresh is in flight at a time.
///
/// Callers that hit a 401 while a refresh is already running await the same task
/// instead of starting another one. The in-flight task is stored *before* the first
/// suspension point, so actor reentrancy cannot start a duplicate refresh. The task
/// inherits the actor's isolation and updates `token` itself, so every waiter sees
/// the new token as soon as the task's value is available.
actor TokenRefresher {
  private(set) var token: String?
  private var refreshTask: Task<String, any Error>?
  private let fetchToken: @Sendable () async throws -> String

  init(token: String? = nil, fetchToken: @escaping @Sendable () async throws -> String) {
    self.token = token
    self.fetchToken = fetchToken
  }

  @discardableResult
  func refresh() async throws -> String {
    if let refreshTask {
      return try await refreshTask.value
    }
    let task = Task {
      do {
        let newToken = try await fetchToken()
        // TODO: Persist the new token (e.g. in the Keychain).
        token = newToken
        return newToken
      } catch {
        // TODO: Delete the stored token and log out of the app.
        token = nil
        throw error
      }
    }
    refreshTask = task
    defer { refreshTask = nil }
    return try await task.value
  }
}

extension TokenRefresher {
  static let live = TokenRefresher {
    let client = HTTPClient(
      transport: URLSessionTransport(), activity: NetworkActivityCenter.shared)
    return try await client.request(AuthEndpoint.accessToken, as: AccessTokenResponse.self)
      .accessToken
  }
}
