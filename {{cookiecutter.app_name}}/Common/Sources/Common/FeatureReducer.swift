//
//  FeatureReducer.swift
//  Common
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

// MARK: FeatureReducer
public protocol FeatureReducer: Reducer, SendableMetatype
where State: Sendable & Hashable, Action == FeatureAction<Self> {
  associatedtype ViewAction: Sendable = Never
  associatedtype InternalAction: Sendable = Never
  associatedtype ChildAction: Sendable = Never
  associatedtype DelegateAction: Sendable = Never

  func reduce(into state: inout State, viewAction: ViewAction) -> Effect<Action>
  func reduce(into state: inout State, internalAction: InternalAction)
    -> Effect<Action>
  func reduce(into state: inout State, childAction: ChildAction) -> Effect<
    Action
  >
  func reduce(into state: inout State, presentedAction: Destination.Action)
    -> Effect<Action>
  func reduceDismissDestination(into state: inout State) -> Effect<Action>

  associatedtype Destination: DestinationReducer = EmptyDestination
  associatedtype ViewState: Equatable = Never
}

extension Reducer where Self: FeatureReducer {
  public typealias Action = FeatureAction<Self>

  public var body: some ReducerOf<Self> {
    Reduce(core)
  }

  public func core(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .destination(.dismiss):
      reduceDismissDestination(into: &state)
    case let .destination(.presented(presentedAction)):
      reduce(into: &state, presentedAction: presentedAction)
    case let .view(viewAction):
      reduce(into: &state, viewAction: viewAction)
    case let .internal(internalAction):
      reduce(into: &state, internalAction: internalAction)
    case let .child(childAction):
      reduce(into: &state, childAction: childAction)
    case .delegate:
      .none
    }
  }

  public func reduce(into state: inout State, viewAction: ViewAction) -> Effect<
    Action
  > {
    .none
  }

  public func reduce(into state: inout State, internalAction: InternalAction)
    -> Effect<Action>
  {
    .none
  }

  public func reduce(into state: inout State, childAction: ChildAction)
    -> Effect<Action>
  {
    .none
  }

  public func reduce(
    into state: inout State, presentedAction: Destination.Action
  ) -> Effect<Action> {
    .none
  }

  public func reduceDismissDestination(into state: inout State) -> Effect<
    Action
  > {
    .none
  }

}

public typealias PresentationStoreOf<R: Reducer> = Store<
  PresentationState<R.State>, PresentationAction<R.Action>
>

// MARK: FeatureAction
public enum FeatureAction<Feature: FeatureReducer> {
  case destination(PresentationAction<Feature.Destination.Action>)
  case view(Feature.ViewAction)
  case `internal`(Feature.InternalAction)
  case child(Feature.ChildAction)
  case delegate(Feature.DelegateAction)
}

// Declared in an extension rather than inline: an inline conformance is resolved
// while building `FeatureReducer`'s requirement signature, which is circular.
extension FeatureAction: Sendable {}

// Written by hand: expanding `@CasePathable` on this enum is circular, because
// `FeatureReducer` requires `Action == FeatureAction<Self>`.
extension FeatureAction: CasePathable {
  public struct AllCasePaths: Sendable {
    public var destination:
      AnyCasePath<FeatureAction, PresentationAction<Feature.Destination.Action>>
    {
      AnyCasePath(
        embed: { .destination($0) },
        extract: {
          guard case let .destination(value) = $0 else { return nil }
          return value
        })
    }

    public var view: AnyCasePath<FeatureAction, Feature.ViewAction> {
      AnyCasePath(
        embed: { .view($0) },
        extract: {
          guard case let .view(value) = $0 else { return nil }
          return value
        })
    }

    public var `internal`: AnyCasePath<FeatureAction, Feature.InternalAction> {
      AnyCasePath(
        embed: { .internal($0) },
        extract: {
          guard case let .internal(value) = $0 else { return nil }
          return value
        })
    }

    public var child: AnyCasePath<FeatureAction, Feature.ChildAction> {
      AnyCasePath(
        embed: { .child($0) },
        extract: {
          guard case let .child(value) = $0 else { return nil }
          return value
        })
    }

    public var delegate: AnyCasePath<FeatureAction, Feature.DelegateAction> {
      AnyCasePath(
        embed: { .delegate($0) },
        extract: {
          guard case let .delegate(value) = $0 else { return nil }
          return value
        })
    }
  }

  public static var allCasePaths: AllCasePaths { AllCasePaths() }
}

// MARK: DestinationReducer
public protocol DestinationReducer: Reducer
where State: Sendable & Hashable, Action: Sendable & CasePathable {}

// MARK: EmptyDestination

public enum EmptyDestination: DestinationReducer {
  public struct State: Sendable, Hashable {}
  public typealias Action = Never
  public func reduce(into state: inout State, action: Never) -> Effect<Action> {
  }
  public func reduceDismissDestination(into state: inout State) -> Effect<
    Action
  > { .none }
}

extension FeatureReducer {

  public func delayedMediumEffect(internal internalAction: InternalAction)
    -> Effect<Action>
  {
    self.delayedMediumEffect(for: .internal(internalAction))
  }

  public func delayedMediumEffect(
    for action: Action
  ) -> Effect<Action> {
    delayedEffect(delay: .seconds(0.6), for: action)
  }

  public func delayedShortEffect(
    for action: Action
  ) -> Effect<Action> {
    delayedEffect(delay: .seconds(0.3), for: action)
  }

  private func delayedEffect(
    delay: Duration,
    for action: Action
  ) -> Effect<Action> {
    @Dependency(\.continuousClock) var clock
    return .run { send in
      try await clock.sleep(for: delay)
      await send(action)
    }
  }
}
