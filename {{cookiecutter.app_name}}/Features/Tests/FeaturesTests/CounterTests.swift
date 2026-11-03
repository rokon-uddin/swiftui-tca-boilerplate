//
//  CounterTests.swift
//  FeaturesTests
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import ComposableArchitecture
import Testing

@testable import Counter

@MainActor
struct CounterTests {
  @Test func incrementAndDecrement() async {
    let store = TestStore(initialState: Counter.State()) {
      Counter()
    }

    await store.send(.view(.incrementButtonTapped)) {
      $0.count = 1
    }
    await store.send(.view(.decrementButtonTapped)) {
      $0.count = 0
    }
  }

  @Test func closeButton_delegatesClose() async {
    let store = TestStore(initialState: Counter.State()) {
      Counter()
    }

    await store.send(.view(.closeButtonTapped))
    await store.receive(\.internal)
    await store.receive(\.delegate)
  }
}
