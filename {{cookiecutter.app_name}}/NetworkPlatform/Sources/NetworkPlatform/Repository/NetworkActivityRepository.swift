//
//  NetworkActivityRepository.swift
//  NetworkPlatform
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Domain
import Utilities

public struct NetworkActivityRepository: Domain.NetworkActivityRepository {
  private let broadcaster: AsyncBroadcaster<NetworkActivity>

  init(broadcaster: AsyncBroadcaster<NetworkActivity>) {
    self.broadcaster = broadcaster
  }

  public func observe() async -> AsyncStream<NetworkActivity> {
    await broadcaster.stream()
  }
}

extension NetworkActivityRepository {
  public static let live = NetworkActivityRepository(broadcaster: NetworkActivityCenter.shared)
}
