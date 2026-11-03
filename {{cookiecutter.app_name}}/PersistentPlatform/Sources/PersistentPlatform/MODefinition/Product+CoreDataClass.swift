//
//  Product+CoreDataClass.swift
//  PersistentPlatform
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import CoreData
import Domain
import Foundation

@objc(Product)
public class Product: NSManagedObject {}

extension Product {
  static func predicate(id: Int) -> NSPredicate {
    NSPredicate(format: "id == %@", "\(id)")
  }

  func update(from product: Domain.Product) {
    id = "\(product.id)"
    title = product.title
    price = product.price
    image = product.image
    category = product.category
    productDescription = product.description
  }
}

// MARK: DomainConvertible

extension Product: DomainConvertible {
  public typealias DomainType = Domain.Product

  /// Must be called on the managed object context's queue.
  public func asDomain() -> Domain.Product {
    Domain.Product(
      id: Int(id) ?? 0, price: price, title: title, image: image,
      category: category, description: productDescription)
  }
}
