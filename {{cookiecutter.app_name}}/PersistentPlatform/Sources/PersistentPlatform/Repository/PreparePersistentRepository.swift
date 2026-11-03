//
//  PreparePersistentRepository.swift
//  PersistentPlatform
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Domain
import Foundation

public struct PreparePersistentRepository: Domain.PrepareRepository {

  private let persistenceController: PersistenceController

  init(persistenceController: PersistenceController) {
    self.persistenceController = persistenceController
  }

  public func prepare() async throws {
    try await persistenceController.prepare()
  }
}

extension PreparePersistentRepository {
  public static let live = PreparePersistentRepository(
    persistenceController: PersistenceController.shared)
  public static let stubbed = PreparePersistentRepository(
    persistenceController: PersistenceController.inMemory)
}
