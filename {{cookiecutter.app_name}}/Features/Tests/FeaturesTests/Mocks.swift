//
//  Mocks.swift
//  FeaturesTests
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Domain
import Foundation

@testable import Product

struct MockUseCase<Input, Output>: UseCase {
  let body: @Sendable (Input) async throws -> Output

  func callAsFunction(input: Input) async throws -> Output {
    try await body(input)
  }
}

struct MockStreamUseCase<Element: Sendable>: StreamUseCase {
  let stream: AsyncStream<Element>

  func callAsFunction(input: Void) async -> AsyncStream<Element> {
    stream
  }
}

/// Streams the test drives by hand, so emissions are deterministic.
struct ControlledStreams {
  let reachability = AsyncStream.makeStream(of: Bool.self)
  let activity = AsyncStream.makeStream(of: NetworkActivity.self)
  let products = AsyncStream.makeStream(of: [Product].self)

  func finishAll() {
    reachability.continuation.finish()
    activity.continuation.finish()
    products.continuation.finish()
  }
}

actor SavedProducts {
  private(set) var values: [Product] = []
  func append(_ product: Product) { values.append(product) }
}

struct TestFailure: LocalizedError {
  var errorDescription: String? { "Something went wrong" }
}

extension ProductClient {
  static func mock(
    streams: ControlledStreams = ControlledStreams(),
    getProduct: @escaping @Sendable (Int) async throws -> Product? = { _ in .mock },
    saveProduct: @escaping @Sendable (Product) async throws -> Void = { _ in }
  ) -> Self {
    ProductClient(
      prepareCoreData: MockUseCase<Void, Void> { _ in },
      getProduct: MockUseCase(body: getProduct),
      saveProduct: MockUseCase(body: saveProduct),
      observeProducts: MockStreamUseCase(stream: streams.products.stream),
      observeReachability: MockStreamUseCase(stream: streams.reachability.stream),
      observeNetworkActivity: MockStreamUseCase(stream: streams.activity.stream))
  }
}

extension Product {
  static let mock = Product(
    id: 2, price: 9.99, title: "Backpack", image: "", category: "bags",
    description: "Fits a laptop")
}
