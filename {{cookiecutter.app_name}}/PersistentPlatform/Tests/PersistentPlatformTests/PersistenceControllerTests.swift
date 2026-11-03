//
//  PersistenceControllerTests.swift
//  PersistentPlatformTests
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Domain
import Testing

@testable import PersistentPlatform

struct PersistenceControllerTests {
  let controller = PersistenceController(inMemory: true)

  @Test func savesAndReadsProductById() async throws {
    try await controller.save(product: .mock(id: 1, title: "One"))
    try await controller.save(product: .mock(id: 2, title: "Two"))

    #expect(try await controller.product(id: 2)?.title == "Two")
    #expect(try await controller.product(id: 1)?.title == "One")
    #expect(try await controller.product(id: 3) == nil)
  }

  @Test func savingSameIdUpdatesInsteadOfDuplicating() async throws {
    try await controller.save(product: .mock(id: 1, title: "Old"))
    try await controller.save(product: .mock(id: 1, title: "New"))

    let products = try await controller.products()
    #expect(products == [.mock(id: 1, title: "New")])
  }

  @Test func concurrentPrepareLoadsStoreOnce() async throws {
    try await withThrowingTaskGroup(of: Void.self) { group in
      for _ in 0..<10 {
        group.addTask { try await controller.prepare() }
      }
      try await group.waitForAll()
    }
    #expect(try await controller.products().isEmpty)
  }

  @Test func observeEmitsSnapshotThenUpdates() async throws {
    try await controller.save(product: .mock(id: 1, title: "A"))

    var iterator = await controller.observeProducts().makeAsyncIterator()
    #expect(await iterator.next()?.map(\.id) == [1])

    try await controller.save(product: .mock(id: 2, title: "B"))
    #expect(await iterator.next()?.map(\.id) == [1, 2])
  }
}

extension Domain.Product {
  static func mock(id: Int, title: String) -> Self {
    .init(
      id: id, price: 9.99, title: title, image: "", category: "test",
      description: "\(title) description")
  }
}
