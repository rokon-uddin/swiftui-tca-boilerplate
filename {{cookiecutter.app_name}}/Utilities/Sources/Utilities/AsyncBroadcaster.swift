//
//  AsyncBroadcaster.swift
//  Utilities
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Foundation

/// Fans out values to any number of `AsyncStream` subscribers.
///
/// `AsyncStream` is single-consumer, so each call to `stream()` registers its own
/// continuation. Continuations are removed when the subscriber's stream terminates.
///
/// With `replayLatest` enabled, a new subscriber immediately receives the most recent
/// value. Because subscription and replay happen in one actor-isolated call, a
/// subscriber can never miss a value yielded between "read current" and "subscribe".
public actor AsyncBroadcaster<Element: Sendable> {
  private var continuations: [UUID: AsyncStream<Element>.Continuation] = [:]
  private var isFinished = false
  private let replayLatest: Bool
  private let bufferingPolicy: AsyncStream<Element>.Continuation.BufferingPolicy
  private var latest: Element?

  /// - Parameters:
  ///   - replayLatest: Deliver the most recent value to new subscribers.
  ///   - bufferingPolicy: Applied to every subscriber's stream. Use `.unbounded` when
  ///     every event matters, `.bufferingNewest(1)` when only the latest state does.
  public init(
    replayLatest: Bool = false,
    bufferingPolicy: AsyncStream<Element>.Continuation.BufferingPolicy = .unbounded
  ) {
    self.replayLatest = replayLatest
    self.bufferingPolicy = bufferingPolicy
  }

  public var subscriberCount: Int { continuations.count }

  /// Returns a new stream that receives every value yielded after subscription.
  public func stream() -> AsyncStream<Element> {
    let (stream, continuation) = AsyncStream.makeStream(
      of: Element.self, bufferingPolicy: bufferingPolicy)
    guard !isFinished else {
      continuation.finish()
      return stream
    }
    if let latest {
      continuation.yield(latest)
    }
    let id = UUID()
    continuations[id] = continuation
    continuation.onTermination = { [weak self] _ in
      Task { await self?.remove(id) }
    }
    return stream
  }

  public func yield(_ element: Element) {
    if replayLatest {
      latest = element
    }
    for continuation in continuations.values {
      continuation.yield(element)
    }
  }

  public func finish() {
    isFinished = true
    for continuation in continuations.values {
      continuation.finish()
    }
    continuations.removeAll()
  }

  private func remove(_ id: UUID) {
    continuations[id] = nil
  }
}
