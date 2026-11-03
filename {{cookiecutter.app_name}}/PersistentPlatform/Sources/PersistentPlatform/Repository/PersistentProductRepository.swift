//
//  PersistentProductRepository.swift
//  PersistentPlatform
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Domain

public struct PersistentProductRepository: Domain.PersistentProductRepository,
  Domain.ObservableProductRepository
{

  private let persistenceController: PersistenceController

  init(persistenceController: PersistenceController) {
    self.persistenceController = persistenceController
  }

  public func create(input: Domain.Product) async throws {
    try await persistenceController.save(product: input)
  }

  public func read(input: Int) async throws -> Domain.Product? {
    try await persistenceController.product(id: input)
  }

  public func observe() async -> AsyncStream<[Domain.Product]> {
    await persistenceController.observeProducts()
  }
}

extension PersistentProductRepository {
  public static let live = PersistentProductRepository(
    persistenceController: PersistenceController.shared)
  /// Backed by an in-memory store; nothing is written to disk.
  public static let stubbed = PersistentProductRepository(
    persistenceController: PersistenceController.inMemory)
}

extension PersistenceController {
  static let inMemory = PersistenceController(inMemory: true)
}
