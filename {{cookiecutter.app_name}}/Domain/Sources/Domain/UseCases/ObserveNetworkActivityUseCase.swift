//
//  ObserveNetworkActivityUseCase.swift
//  Domain
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Foundation

public typealias ObserveNetworkActivityUseCaseType = StreamUseCase<Void, NetworkActivity>

public struct ObserveNetworkActivityUseCase: StreamUseCase {
  let observe: @Sendable () async -> AsyncStream<NetworkActivity>

  public init<R: NetworkActivityRepository>(repository: R) {
    self.observe = repository.observe
  }

  public func callAsFunction(input: Void) async -> AsyncStream<NetworkActivity> {
    await observe()
  }
}
