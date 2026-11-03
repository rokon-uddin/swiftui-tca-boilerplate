//
//  UseCaseTests.swift
//  DomainTests
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Testing

@testable import Domain

struct UseCaseTests {
  @Test func productUseCase_readsFromRepository() async throws {
    let useCase = ProductUseCase(repository: InMemoryProductRepository(products: [.mock]))
    #expect(try await useCase(input: 1) == .mock)
    #expect(try await useCase(input: 99) == nil)
  }

  @Test func saveProductUseCase_writesToRepository() async throws {
    let repository = InMemoryProductRepository()
    let useCase = SaveProductUseCase(repository: repository)
    try await useCase(input: .mock)
    #expect(await repository.store.products == [.mock])
  }

  @Test func prepareUseCase_propagatesFailure() async {
    let useCase = PrepareCoreDataUseCase(repository: FailingPrepareRepository())
    await #expect(throws: AppError.databaseCorrupted(nil)) {
      try await useCase()
    }
  }

  @Test func observeReachabilityUseCase_forwardsStream() async {
    let useCase = ObserveReachabilityUseCase(repository: FixedReachabilityRepository(values: [true, false]))
    var values: [Bool] = []
    for await value in await useCase() { values.append(value) }
    #expect(values == [true, false])
  }
}

private actor ProductStore {
  var products: [Product]
  init(products: [Product]) { self.products = products }
  func append(_ product: Product) { products.append(product) }
}

private struct InMemoryProductRepository: RemoteProductRepository {
  let store: ProductStore

  init(products: [Product] = []) {
    store = ProductStore(products: products)
  }

  func create(input: Product) async throws {
    await store.append(input)
  }

  func read(input: Int) async throws -> Product? {
    await store.products.first { $0.id == input }
  }

  static var live: InMemoryProductRepository { .init() }
  static var stubbed: InMemoryProductRepository { .init() }
}

private struct FailingPrepareRepository: PrepareRepository {
  func prepare() async throws {
    throw AppError.databaseCorrupted(nil)
  }
}

private struct FixedReachabilityRepository: ReachabilityRepository {
  let values: [Bool]

  func observe() -> AsyncStream<Bool> {
    AsyncStream { continuation in
      for value in values { continuation.yield(value) }
      continuation.finish()
    }
  }
}

extension Product {
  fileprivate static let mock = Product(
    id: 1, price: 1, title: "Mock", image: "", category: "", description: "")
}
