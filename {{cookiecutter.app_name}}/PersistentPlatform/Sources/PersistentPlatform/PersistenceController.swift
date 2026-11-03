//
//  PersistenceController.swift
//  PersistentPlatform
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import CoreData
import Domain
import Utilities

/// Owns the Core Data stack.
///
/// Every operation runs inside `context.perform` on a private background context
/// that never leaves the actor. Only `Sendable` domain values cross the actor
/// boundary; `NSManagedObject`s stay on the context's queue.
actor PersistenceController {
  static let shared = PersistenceController()

  /// Loaded once per process. Loading the same model more than once makes Core Data
  /// unable to map `NSManagedObject` subclasses to a unique entity.
  /// `NSManagedObjectModel` is immutable once a coordinator uses it.
  private nonisolated(unsafe) static let model: NSManagedObjectModel = {
    do {
      return try NSManagedObjectModel.managedObjectModel(forResource: Constants.CoreData.model)
    } catch {
      fatalError("Unable to load Core Data model: \(error)")
    }
  }()

  private let container: NSPersistentContainer
  /// Created on first use, after `prepare()` has loaded the store.
  private lazy var context: NSManagedObjectContext = {
    let context = container.newBackgroundContext()
    context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    return context
  }()
  private var loadTask: Task<Void, any Error>?
  private let productChanges = AsyncBroadcaster<[Domain.Product]>(
    replayLatest: true, bufferingPolicy: .bufferingNewest(1))

  init(inMemory: Bool = false) {
    container = NSPersistentContainer(name: Constants.CoreData.model, managedObjectModel: Self.model)
    let description = container.persistentStoreDescriptions.first
    if inMemory {
      description?.type = NSInMemoryStoreType
      description?.url = nil
    }
    description?.shouldInferMappingModelAutomatically = false
    description?.shouldMigrateStoreAutomatically = false
    description?.shouldAddStoreAsynchronously = false
  }
}

// MARK: Preparation

extension PersistenceController {

  /// Loads the persistent store once. Concurrent callers await the same load, so
  /// actor reentrancy cannot load the store twice.
  func prepare() async throws {
    if let loadTask {
      return try await loadTask.value
    }
    let task = Task { try await loadPersistentStore() }
    loadTask = task
    do {
      try await task.value
    } catch {
      loadTask = nil
      throw error
    }
    await publishProducts()
  }

  func rebuild() async throws {
    guard let storeURL = container.persistentStoreDescriptions.first?.url else {
      throw AppError.databaseCorrupted(
        "PersistentContainer was not set up properly.")
    }

    try NSPersistentStoreCoordinator.destroyStore(at: storeURL)
    loadTask = nil
    try await prepare()
  }

  private func loadPersistentStore() async throws {
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
      container.loadPersistentStores { description, error in
        if let error {
          let message = "Was unable to load store \(error)."
          continuation.resume(throwing: AppError.databaseCorrupted(message))
          return
        }
        Logger.info("Persistent store loaded: \(description)")
        continuation.resume()
      }
    }
  }
}

// MARK: Foundation

extension PersistenceController {

  /// Fetches objects and converts them to domain values on the context's queue.
  ///
  /// `configure` builds the predicate, sort descriptors, etc. inside the queue, so
  /// non-Sendable Foundation types never cross the isolation boundary.
  func fetch<MO: NSManagedObject & DomainConvertible>(
    _ entityType: MO.Type,
    configure: @escaping @Sendable (NSFetchRequest<MO>) -> Void = { _ in }
  ) async throws -> [MO.DomainType] where MO.DomainType: Sendable {
    try await prepare()
    return try await context.perform { [context] in
      let request = NSFetchRequest<MO>(entityName: String(describing: entityType))
      configure(request)
      return try context.fetch(request).map { $0.asDomain() }
    }
  }

  /// Updates the first object matching the configured request, creating it when
  /// none exists.
  func upsert<MO: NSManagedObject>(
    _ entityType: MO.Type,
    configure: @escaping @Sendable (NSFetchRequest<MO>) -> Void,
    commitChanges: @escaping @Sendable (MO) -> Void
  ) async throws {
    try await prepare()
    try await context.perform { [context] in
      let request = NSFetchRequest<MO>(entityName: String(describing: entityType))
      configure(request)
      request.fetchLimit = 1
      let object = try context.fetch(request).first ?? MO(context: context)
      commitChanges(object)
      try Self.save(context)
    }
  }

  func purge<MO: NSManagedObject>(
    _ entityType: MO.Type,
    configure: @escaping @Sendable (NSFetchRequest<MO>) -> Void = { _ in }
  ) async throws {
    try await prepare()
    try await context.perform { [context] in
      let request = NSFetchRequest<MO>(entityName: String(describing: entityType))
      configure(request)
      for object in try context.fetch(request) {
        context.delete(object)
      }
      try Self.save(context)
    }
  }

  private static func save(_ context: NSManagedObjectContext) throws {
    guard context.hasChanges else { return }
    do {
      try context.save()
    } catch {
      context.rollback()
      throw AppError.databaseCorrupted("Unable to save context: \(error)")
    }
  }
}

// MARK: Public API

extension PersistenceController {

  func save(product: Domain.Product) async throws {
    try await upsert(
      Product.self,
      configure: { $0.predicate = Product.predicate(id: product.id) },
      commitChanges: { $0.update(from: product) })
    await publishProducts()
  }

  func product(id: Int) async throws -> Domain.Product? {
    try await fetch(Product.self) {
      $0.predicate = Product.predicate(id: id)
      $0.fetchLimit = 1
    }.first
  }

  func products() async throws -> [Domain.Product] {
    try await fetch(Product.self) {
      $0.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
    }
  }

  /// Emits the current products immediately, then again after every save.
  func observeProducts() async -> AsyncStream<[Domain.Product]> {
    do {
      try await prepare()
    } catch {
      Logger.error(error.localizedDescription)
    }
    return await productChanges.stream()
  }

  private func publishProducts() async {
    do {
      await productChanges.yield(try await products())
    } catch {
      Logger.error(error.localizedDescription)
    }
  }
}
