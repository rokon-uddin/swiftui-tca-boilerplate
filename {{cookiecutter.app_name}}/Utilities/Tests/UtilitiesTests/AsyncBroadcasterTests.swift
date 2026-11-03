//
//  AsyncBroadcasterTests.swift
//  UtilitiesTests
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Testing

@testable import Utilities

struct AsyncBroadcasterTests {
  @Test func deliversValuesToEverySubscriber() async {
    let broadcaster = AsyncBroadcaster<Int>()
    let first = await broadcaster.stream()
    let second = await broadcaster.stream()

    await broadcaster.yield(1)
    await broadcaster.yield(2)
    await broadcaster.finish()

    #expect(await Array(first) == [1, 2])
    #expect(await Array(second) == [1, 2])
  }

  @Test func replaysLatestValueToNewSubscribers() async {
    let broadcaster = AsyncBroadcaster<Int>(replayLatest: true)
    await broadcaster.yield(1)
    await broadcaster.yield(2)
    let late = await broadcaster.stream()
    await broadcaster.yield(3)
    await broadcaster.finish()

    #expect(await Array(late) == [2, 3])
  }

  @Test func doesNotReplayByDefault() async {
    let broadcaster = AsyncBroadcaster<Int>()
    await broadcaster.yield(1)
    let late = await broadcaster.stream()
    await broadcaster.finish()

    #expect(await Array(late).isEmpty)
  }

  @Test func streamAfterFinishCompletesImmediately() async {
    let broadcaster = AsyncBroadcaster<Int>()
    await broadcaster.finish()
    let stream = await broadcaster.stream()
    #expect(await Array(stream).isEmpty)
  }

  @Test func cancelledSubscriberIsRemoved() async {
    let broadcaster = AsyncBroadcaster<Int>()
    let task = Task {
      for await _ in await broadcaster.stream() {}
    }
    while await broadcaster.subscriberCount == 0 { await Task.yield() }
    task.cancel()
    await task.value
    while await broadcaster.subscriberCount != 0 { await Task.yield() }
    #expect(await broadcaster.subscriberCount == 0)
  }
}

extension Array {
  init(_ sequence: AsyncStream<Element>) async {
    var result: [Element] = []
    for await element in sequence { result.append(element) }
    self = result
  }
}
