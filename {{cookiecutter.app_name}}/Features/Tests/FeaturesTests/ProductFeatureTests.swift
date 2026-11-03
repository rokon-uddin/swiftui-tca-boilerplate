//
//  ProductFeatureTests.swift
//  FeaturesTests
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import ComposableArchitecture
import Counter
import Domain
import Foundation
import Testing

@testable import Product

@MainActor
struct ProductFeatureTests {

  @Test func task_loadsProductAndFollowsStreams() async {
    let streams = ControlledStreams()
    let store = TestStore(initialState: ProductFeature.State()) {
      ProductFeature()
    } withDependencies: {
      $0.productClient = .mock(streams: streams)
    }

    let task = await store.send(.view(.task))
    await store.receive(\.internal.productResponse.success) {
      $0.product = .mock
    }

    streams.reachability.continuation.yield(false)
    await store.receive(\.internal.reachabilityChanged) {
      $0.isOnline = false
    }

    streams.products.continuation.yield([.mock])
    await store.receive(\.internal.savedProductsChanged) {
      $0.savedProducts = [.mock]
    }

    let requestID = UUID()
    streams.activity.continuation.yield(.started(id: requestID, path: "/products/2"))
    await store.receive(\.internal.networkActivity) {
      $0.inFlightRequests = [requestID]
      #expect($0.isLoading)
    }
    streams.activity.continuation.yield(.finished(id: requestID, statusCode: 200))
    await store.receive(\.internal.networkActivity) {
      $0.inFlightRequests = []
    }

    await task.cancel()
  }

  @Test func task_whenLoadFails_showsError() async {
    let streams = ControlledStreams()
    streams.finishAll()
    let store = TestStore(initialState: ProductFeature.State()) {
      ProductFeature()
    } withDependencies: {
      $0.productClient = .mock(streams: streams, getProduct: { _ in throw TestFailure() })
    }

    await store.send(.view(.task))
    await store.receive(\.internal.productResponse.failure) {
      $0.errorMessage = "Something went wrong"
    }
  }

  @Test func save_withoutProduct_doesNothing() async {
    let store = TestStore(initialState: ProductFeature.State()) {
      ProductFeature()
    } withDependencies: {
      $0.productClient = .mock(saveProduct: { _ in Issue.record("save should not be called") })
    }

    await store.send(.view(.save))
  }

  @Test func save_withProduct_persistsIt() async {
    let saved = SavedProducts()
    var state = ProductFeature.State()
    state.product = .mock
    let store = TestStore(initialState: state) {
      ProductFeature()
    } withDependencies: {
      $0.productClient = .mock(saveProduct: { await saved.append($0) })
    }

    await store.send(.view(.save))
    await store.finish()
    #expect(await saved.values == [.mock])
  }

  @Test func save_whenItFails_showsError() async {
    var state = ProductFeature.State()
    state.product = .mock
    let store = TestStore(initialState: state) {
      ProductFeature()
    } withDependencies: {
      $0.productClient = .mock(saveProduct: { _ in throw TestFailure() })
    }

    await store.send(.view(.save))
    await store.receive(\.internal.saveFailed) {
      $0.errorMessage = "Something went wrong"
    }
  }

  @Test func sheet_closesWhenCounterDelegatesClose() async {
    let store = TestStore(initialState: ProductFeature.State()) {
      ProductFeature()
    } withDependencies: {
      $0.productClient = .mock()
    }

    await store.send(.view(.showSheet)) {
      $0.destination = .sheet(Counter.State())
    }
    await store.send(.destination(.presented(.sheet(.view(.incrementButtonTapped))))) {
      $0.destination = .sheet(Counter.State(count: 1))
    }
    await store.send(.destination(.presented(.sheet(.view(.closeButtonTapped)))))
    await store.receive(\.destination.presented.sheet.internal)
    await store.receive(\.destination.presented.sheet.delegate)
    await store.receive(\.internal.dismissDestination) {
      $0.destination = nil
    }
  }

  @Test func fullScreenCover_closesWhenCounterDelegatesClose() async {
    let store = TestStore(initialState: ProductFeature.State()) {
      ProductFeature()
    } withDependencies: {
      $0.productClient = .mock()
    }

    await store.send(.view(.showFullScreenCover)) {
      $0.destination = .fullScreenCover(Counter.State())
    }
    await store.send(.destination(.presented(.fullScreenCover(.view(.closeButtonTapped)))))
    await store.receive(\.destination.presented.fullScreenCover.internal)
    await store.receive(\.destination.presented.fullScreenCover.delegate)
    await store.receive(\.internal.dismissDestination) {
      $0.destination = nil
    }
  }
}
