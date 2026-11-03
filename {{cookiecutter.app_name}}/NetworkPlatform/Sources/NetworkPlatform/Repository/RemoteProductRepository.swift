//
//  RemoteProductRepository.swift
//  NetworkPlatform
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Domain

public struct RemoteProductRepository: Domain.RemoteProductRepository {

  private let client: HTTPClient

  init(client: HTTPClient) {
    self.client = client
  }

  public func create(input: Product) async throws {
    fatalError("Unimplemented")
  }

  public func read(input: Int) async throws -> Product? {
    try await client.request(AppEndpoint.product(id: input), as: Product.self)
  }
}

extension RemoteProductRepository {
  public static let live = RemoteProductRepository(
    client: HTTPClient(
      transport: URLSessionTransport(),
      activity: NetworkActivityCenter.shared,
      tokenRefresher: .live))
  public static let stubbed = RemoteProductRepository(
    client: HTTPClient(
      transport: StubTransport(),
      activity: NetworkActivityCenter.shared))
}
