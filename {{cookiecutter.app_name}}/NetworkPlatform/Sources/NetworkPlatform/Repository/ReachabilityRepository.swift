//
//  ReachabilityRepository.swift
//  NetworkPlatform
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Domain
import Foundation
import Network

public struct ReachabilityRepository: Domain.ReachabilityRepository {
  private let makeStream: @Sendable () -> AsyncStream<Bool>

  init(makeStream: @escaping @Sendable () -> AsyncStream<Bool>) {
    self.makeStream = makeStream
  }

  public func observe() -> AsyncStream<Bool> {
    makeStream()
  }
}

extension ReachabilityRepository {
  /// Backed by `NWPathMonitor`. Each subscriber gets its own monitor, which is
  /// cancelled when the subscriber stops iterating.
  public static let live = ReachabilityRepository {
    let (stream, continuation) = AsyncStream.makeStream(
      of: Bool.self, bufferingPolicy: .bufferingNewest(1))
    let monitor = NWPathMonitor()
    monitor.pathUpdateHandler = { path in
      continuation.yield(path.status == .satisfied)
    }
    continuation.onTermination = { _ in
      monitor.cancel()
    }
    monitor.start(queue: DispatchQueue(label: "NetworkPlatform.Reachability"))
    return stream
  }

  public static let online = ReachabilityRepository {
    AsyncStream { continuation in
      continuation.yield(true)
      continuation.finish()
    }
  }
}
