//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

import Common
import ComposableArchitecture
import Domain
import Foundation

public struct ___VARIABLE_moduleName___Feature: FeatureReducer {

  public init() {}

  @ObservableState
  public struct State: Equatable, Hashable, Sendable {
    public init() {}

    @Presents var destination: Destination.State?
  }

  public enum ViewAction: Sendable {
    case task
  }

  public enum InternalAction: Sendable {

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
      // Start long-lived work (e.g. `for await` over an AsyncStream) here.
      // It is cancelled automatically when the view's `.task` ends.
      return .none
    }
  }

  public func reduce(into state: inout State, presentedAction: Destination.Action) -> Effect<Action> {
    .none
  }

  public func reduce(into state: inout State, internalAction: InternalAction) -> Effect<Action> {
    switch internalAction {

    }
  }

  public struct Destination: DestinationReducer {

    public init() {}

    @dynamicMemberLookup
    @CasePathable
    public enum State: Hashable, Sendable {

    }

    @CasePathable
    public enum Action: Sendable {

    }

    public var body: some ReducerOf<Self> {
      // Attach child reducers with `.ifCaseLet(\.child, action: \.child) { Child() }`.
      EmptyReducer()
    }
  }
}
