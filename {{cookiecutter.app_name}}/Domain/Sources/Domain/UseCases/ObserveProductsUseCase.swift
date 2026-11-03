//
//  ObserveProductsUseCase.swift
//  Domain
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Foundation

public typealias ObserveProductsUseCaseType = StreamUseCase<Void, [Product]>

public struct ObserveProductsUseCase: StreamUseCase {
  let observe: @Sendable () async -> AsyncStream<[Product]>

  public init<R: ObservableProductRepository>(repository: R)
  where R.ObserveOutput == [Product] {
    self.observe = repository.observe
  }

  public func callAsFunction(input: Void) async -> AsyncStream<[Product]> {
    await observe()
  }
}
