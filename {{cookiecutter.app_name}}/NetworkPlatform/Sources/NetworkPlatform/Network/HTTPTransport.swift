//
//  HTTPTransport.swift
//  NetworkPlatform
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Domain
import Foundation

/// Sends a request and returns the raw response. Swapping the transport is how the
/// client switches between live and stubbed networking.
protocol HTTPTransport: Sendable {
  func send(_ request: URLRequest, stubFileName: String?) async throws -> (Data, HTTPURLResponse)
}

struct URLSessionTransport: HTTPTransport {
  let session: URLSession

  init(session: URLSession = .shared) {
    self.session = session
  }

  func send(_ request: URLRequest, stubFileName _: String?) async throws -> (Data, HTTPURLResponse) {
    let (data, response) = try await session.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }
    return (data, httpResponse)
  }
}

/// Serves bundled JSON files instead of hitting the network.
struct StubTransport: HTTPTransport {
  var statusCode = 200

  func send(_ request: URLRequest, stubFileName: String?) async throws -> (Data, HTTPURLResponse) {
    guard let stubFileName,
      let url = Bundle.module.url(forResource: stubFileName, withExtension: "json")
    else {
      throw AppError.notFound
    }
    let data = try Data(contentsOf: url)
    let response = HTTPURLResponse(
      url: request.url ?? url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    return (data, response)
  }
}
