//
//  Repository.swift
//  Domain
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Foundation

public protocol PrepareRepository: Sendable {
  func prepare() async throws
}

public protocol CreateRepository: Sendable {
  associatedtype CreateInput = Never
  associatedtype CreateOutput = Never
  associatedtype RepositoryType

  func create(input: CreateInput) async throws -> CreateOutput
  static var live: RepositoryType { get }
  static var stubbed: RepositoryType { get }
}

public protocol ReadRepository: Sendable {
  associatedtype ReadInput = Never
  associatedtype ReadOutput = Never
  associatedtype RepositoryType

  func read(input: ReadInput) async throws -> ReadOutput
  static var live: RepositoryType { get }
  static var stubbed: RepositoryType { get }
}

public protocol ReadAllRepository: Sendable {
  associatedtype ReadInput = Never
  associatedtype ReadOutput = Never
  associatedtype RepositoryType

  func readAll(input: ReadInput) async throws -> [ReadOutput]
  static var live: RepositoryType { get }
  static var stubbed: RepositoryType { get }
}

public protocol UpdateRepository: Sendable {
  associatedtype UpdateInput = Never
  associatedtype UpdateOutput = Never
  associatedtype RepositoryType

  func update(input: UpdateInput) async throws -> UpdateOutput
  static var live: RepositoryType { get }
  static var stubbed: RepositoryType { get }
}

public protocol DeleteRepository: Sendable {
  associatedtype DeleteInput = Never
  associatedtype DeleteOutput = Never
  associatedtype RepositoryType

  func delete(input: DeleteInput) async throws -> DeleteOutput
  static var live: RepositoryType { get }
  static var stubbed: RepositoryType { get }
}

/// A repository that publishes its current contents whenever they change.
public protocol ObserveRepository: Sendable {
  associatedtype ObserveOutput: Sendable

  func observe() async -> AsyncStream<ObserveOutput>
}

public protocol ReachabilityRepository: Sendable {
  /// Emits `true` when the network is reachable, `false` otherwise.
  func observe() -> AsyncStream<Bool>
}

public protocol NetworkActivityRepository: Sendable {
  func observe() async -> AsyncStream<NetworkActivity>
}

public typealias RemoteProductRepository = CreateRepository & ReadRepository

public typealias PersistentProductRepository = CreateRepository & ReadRepository

public typealias ObservableProductRepository = ObserveRepository
