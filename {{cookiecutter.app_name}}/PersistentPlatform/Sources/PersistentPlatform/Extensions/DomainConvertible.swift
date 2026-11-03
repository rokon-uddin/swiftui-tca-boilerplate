//
//  DomainConvertible.swift
//  PersistentPlatform
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import CoreData
import Domain
import Foundation

/// Converts a managed object into a `Sendable` domain value.
///
/// Conversion must happen on the managed object context's queue (inside
/// `context.perform`) so the result can safely leave it.
public protocol DomainConvertible {
  associatedtype DomainType
  func asDomain() -> DomainType
}

extension Array: DomainConvertible where Element: DomainConvertible {
  public func asDomain() -> [Element.DomainType] {
    self.map { $0.asDomain() }
  }
}

extension Set: DomainConvertible where Element: DomainConvertible {
  public func asDomain() -> [Element.DomainType] {
    self.map { $0.asDomain() }
  }
}

extension NSOrderedSet {
  func asDomain<DomainElement, EntityType: DomainConvertible>(
    entityElementType: EntityType.Type
  ) -> [DomainElement] where EntityType.DomainType == DomainElement {
    self.compactMap { ($0 as? EntityType)?.asDomain() }
  }
}
