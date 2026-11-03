//
//  HTTPClientTests.swift
//  NetworkPlatformTests
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Domain
import Foundation
import Testing
import Utilities

@testable import NetworkPlatform

struct HTTPClientTests {
  @Test func decodesStubbedProduct() async throws {
    let client = HTTPClient(transport: StubTransport())
    let product = try await client.request(AppEndpoint.product(id: 1), as: Product.self)
    #expect(product.id == 1)
    #expect(product.title == "Apple Watch")
  }

  @Test func publishesStartedAndFinishedActivity() async throws {
    let broadcaster = AsyncBroadcaster<NetworkActivity>()
    let events = await broadcaster.stream()
    let client = HTTPClient(transport: StubTransport(), activity: broadcaster)

    _ = try await client.request(AppEndpoint.product(id: 1), as: Product.self)
    await broadcaster.finish()

    var received: [NetworkActivity] = []
    for await event in events { received.append(event) }
    #expect(received.count == 2)
    guard case let .started(startID, path) = received.first,
      case let .finished(finishID, statusCode) = received.last
    else {
      Issue.record("Unexpected events: \(received)")
      return
    }
    #expect(startID == finishID)
    #expect(path == "/products/1")
    #expect(statusCode == 200)
  }

  @Test func mapsErrorStatusCodes() async {
    let client = HTTPClient(transport: StubTransport(statusCode: 500))
    await #expect(throws: AppError.httpStatus(code: 500)) {
      try await client.request(AppEndpoint.product(id: 1), as: Product.self)
    }
  }

  @Test func refreshesTokenOnceAndRetriesAfterUnauthorized() async throws {
    let transport = UnauthorizedOnceTransport()
    let refresher = TokenRefresher { "fresh-token" }
    let client = HTTPClient(transport: transport, tokenRefresher: refresher)

    _ = try await client.request(AuthorizedEndpoint(), as: Product.self)

    #expect(await refresher.token == "fresh-token")
    #expect(await transport.authorizationHeaders == [nil, "Bearer fresh-token"])
  }

  @Test func concurrentRefreshesShareOneFetch() async throws {
    let counter = Counter()
    let refresher = TokenRefresher {
      await counter.increment()
      try await Task.sleep(for: .milliseconds(50))
      return "token"
    }
    try await withThrowingTaskGroup(of: String.self) { group in
      for _ in 0..<5 {
        group.addTask { try await refresher.refresh() }
      }
      for try await token in group {
        #expect(token == "token")
      }
    }
    #expect(await counter.value == 1)
  }
}

private struct AuthorizedEndpoint: Endpoint {
  var baseURL: URL { URL(string: "https://example.com")! }
  var path: String { "/products/1" }
  var method: HTTPMethod { .get }
  var stubFileName: String? { "Product" }
  var requiresAuth: Bool { true }
}

private actor UnauthorizedOnceTransport: HTTPTransport {
  private(set) var authorizationHeaders: [String?] = []

  func send(_ request: URLRequest, stubFileName: String?) async throws -> (Data, HTTPURLResponse) {
    authorizationHeaders.append(request.value(forHTTPHeaderField: "Authorization"))
    let statusCode = authorizationHeaders.count == 1 ? 401 : 200
    return try await StubTransport(statusCode: statusCode).send(request, stubFileName: stubFileName)
  }
}

private actor Counter {
  private(set) var value = 0
  func increment() { value += 1 }
}
