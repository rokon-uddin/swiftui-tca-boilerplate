//
//  ObserveReachabilityUseCase.swift
//  Domain
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Foundation

public typealias ObserveReachabilityUseCaseType = StreamUseCase<Void, Bool>

public struct ObserveReachabilityUseCase: StreamUseCase {
  let observe: @Sendable () -> AsyncStream<Bool>

  public init<R: ReachabilityRepository>(repository: R) {
    self.observe = repository.observe
  }

  public func callAsFunction(input: Void) async -> AsyncStream<Bool> {
    observe()
  }
}
