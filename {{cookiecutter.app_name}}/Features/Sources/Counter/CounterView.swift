//
//  CounterView.swift
//  Features
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Common
import ComposableArchitecture
import SwiftUI

public struct CounterView: View {
  let store: StoreOf<Counter>

  public init(store: StoreOf<Counter>) {
    self.store = store
  }

  public var body: some View {
    VStack(spacing: 16) {
      HStack {
        Button("Decrement", systemImage: "minus") {
          store.send(.view(.decrementButtonTapped))
        }

        Text("\(store.count)")
          .monospacedDigit()

        Button("Increment", systemImage: "plus") {
          store.send(.view(.incrementButtonTapped))
        }
      }
      .labelStyle(.iconOnly)

      Button("Dismiss") {
        store.send(.view(.closeButtonTapped))
      }
      .buttonStyle(.borderedProminent)
    }
  }
}

#Preview {
  CounterView(
    store: Store(initialState: Counter.State()) {
      Counter()
    }
  )
}
