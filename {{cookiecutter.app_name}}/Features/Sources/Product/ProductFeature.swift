//
//  ProductFeature.swift
//  Features
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Common
import ComposableArchitecture
import Counter
import Domain
import Foundation
import Utilities

public struct ProductFeature: FeatureReducer {

  @Dependency(\.productClient) var productClient

  public init() {}

  @ObservableState
  public struct State: Equatable, Hashable, Sendable {
    public init() {}

    @Presents var destination: Destination.State?
    var product: Product?
    var savedProducts: [Product] = []
    var isOnline = true
    var inFlightRequests: Set<UUID> = []
    var errorMessage: String?

    var isLoading: Bool { !inFlightRequests.isEmpty }
  }

  public enum ViewAction: Sendable {
    case task
    case showSheet
    case showFullScreenCover
    case save
  }

  @CasePathable
  public enum InternalAction: Sendable {
    case dismissDestination
    case productResponse(Result<Product?, any Error>)
    case saveFailed(String)
    case reachabilityChanged(Bool)
    case networkActivity(NetworkActivity)
    case savedProductsChanged([Product])
  }

  enum CancelID {
    case reachability
    case networkActivity
    case savedProducts
  }

  public var body: some ReducerOf<Self> {
    Reduce(core)
      .ifLet(\.$destination, action: \.destination) {
        Destination()
      }
  }

  public func reduce(into state: inout State, viewAction: ViewAction) -> Effect<Action> {
    switch viewAction {
    case .task:
      // Long-lived effects are tied to the view's `.task`, so they are cancelled
      // automatically when the view disappears.
      return .merge(
        observeNetworkActivity(),
        observeReachability(),
        observeSavedProducts(),
        loadProduct(id: 2)
      )

    case .showSheet:
      state.destination = .sheet(.init())
      return .none

    case .showFullScreenCover:
      state.destination = .fullScreenCover(.init())
      return .none

    case .save:
      guard let product = state.product else { return .none }
      return .run { [productClient] send in
        do {
          try await productClient.saveProduct(input: product)
        } catch {
          await send(.internal(.saveFailed(error.localizedDescription)))
        }
      }
    }
  }

  public func reduce(
    into state: inout State, presentedAction: Destination.Action
  ) -> Effect<Action> {
    switch presentedAction {
    case .sheet(.delegate(.close)):
      return .send(.internal(.dismissDestination))

    case .fullScreenCover(.delegate(.close)):
      return .send(.internal(.dismissDestination))

    default:
      return .none
    }
  }

  public func reduce(into state: inout State, internalAction: InternalAction) -> Effect<Action> {
    switch internalAction {
    case let .productResponse(.success(product)):
      state.product = product
      state.errorMessage = nil
      return .none

    case let .productResponse(.failure(error)):
      Logger.error(error.localizedDescription)
      state.errorMessage = error.localizedDescription
      return .none

    case let .saveFailed(message):
      Logger.error(message)
      state.errorMessage = message
      return .none

    case let .reachabilityChanged(isOnline):
      state.isOnline = isOnline
      return .none

    case let .networkActivity(activity):
      switch activity {
      case let .started(id, _):
        state.inFlightRequests.insert(id)
      case let .finished(id, _), let .failed(id, _):
        state.inFlightRequests.remove(id)
      }
      return .none

    case let .savedProductsChanged(products):
      state.savedProducts = products
      return .none

    case .dismissDestination:
      state.destination = nil
      return .none
    }
  }

  // MARK: Effects

  private func loadProduct(id: Int) -> Effect<Action> {
    .run { [productClient] send in
      do {
        try await productClient.prepareCoreData()
      } catch {
        Logger.error(error.localizedDescription)
      }
      do {
        let product = try await productClient.getProduct(input: id)
        await send(.internal(.productResponse(.success(product))))
      } catch {
        await send(.internal(.productResponse(.failure(error))))
      }
    }
  }

  private func observeReachability() -> Effect<Action> {
    .run { [productClient] send in
      for await isOnline in await productClient.observeReachability() {
        await send(.internal(.reachabilityChanged(isOnline)))
      }
    }
    .cancellable(id: CancelID.reachability, cancelInFlight: true)
  }

  private func observeNetworkActivity() -> Effect<Action> {
    .run { [productClient] send in
      for await activity in await productClient.observeNetworkActivity() {
        await send(.internal(.networkActivity(activity)))
      }
    }
    .cancellable(id: CancelID.networkActivity, cancelInFlight: true)
  }

  private func observeSavedProducts() -> Effect<Action> {
    .run { [productClient] send in
      for await products in await productClient.observeProducts() {
        await send(.internal(.savedProductsChanged(products)))
      }
    }
    .cancellable(id: CancelID.savedProducts, cancelInFlight: true)
  }

  public struct Destination: DestinationReducer {

    public init() {}

    @dynamicMemberLookup
    @CasePathable
    public enum State: Hashable, Sendable {
      case sheet(Counter.State)
      case fullScreenCover(Counter.State)
    }

    @CasePathable
    public enum Action: Sendable {
      case sheet(Counter.Action)
      case fullScreenCover(Counter.Action)
    }

    public var body: some ReducerOf<Self> {
      EmptyReducer()
        .ifCaseLet(\.sheet, action: \.sheet) {
          Counter()
        }
        .ifCaseLet(\.fullScreenCover, action: \.fullScreenCover) {
          Counter()
        }
    }
  }
}
