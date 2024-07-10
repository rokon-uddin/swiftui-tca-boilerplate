//
//  ProductView.swift
//  Features
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Common
import ComposableArchitecture
import Counter
import SwiftUI

@MainActor
public struct ProductView: View {
  let store: StoreOf<ProductFeature>

  public init(store: StoreOf<ProductFeature>) {
    self.store = store
  }

  public var body: some View {
    WithPerceptionTracking {
      VStack {
        VStack {
          Text("\(store.product?.title ?? "Unknown")")
          Spacer()
            .frame(height: 20)
          Text("\(store.product?.description ?? "Unknown")")
        }
        .padding()

        Form {
          Button("Save") {
            store.send(.view(.save))
          }

          Button {
            store.send(.view(.showSheet))
          } label: {
            Text("Sheet")
          }

          Button {
            store.send(.view(.showFullScreenCover))
          } label: {
            Text("Full Screen Cover")
          }
        }
      }
      .onAppear {
        store.send(.view(.onAppear))
      }
      .destinations(with: store)
    }
  }
}

extension StoreOf<ProductFeature> {
  fileprivate var bindableDestination:
    ComposableArchitecture.Bindable<StoreOf<ProductFeature>>
  {
    return ComposableArchitecture.Bindable(self)
  }
}

@MainActor
extension View {
  fileprivate func destinations(with store: StoreOf<ProductFeature>) -> some View {
    let bindableDestination = store.bindableDestination
    return showSheet(with: bindableDestination)
      .showFulllScreenCover(with: bindableDestination)
  }

  private func showSheet(
    with destinationStore: ComposableArchitecture.Bindable<StoreOf<ProductFeature>>
  ) -> some View {
    let destinationStore = destinationStore.scope(
      state: \.destination?.sheet,
      action: \.destination.sheet)

    return sheet(item: destinationStore) { store in
      CounterView(store: store)
    }
  }

  private func showFulllScreenCover(
    with destinationStore: ComposableArchitecture.Bindable<StoreOf<ProductFeature>>
  ) -> some View {
    let destinationStore = destinationStore.scope(
      state: \.destination?.fullScreenCover,
      action: \.destination.fullScreenCover)

    return fullScreenCover(item: destinationStore) { store in
      CounterView(store: store)
    }
  }
}

#Preview {
  ProductView(
    store:
      .init(
        initialState: ProductFeature.State(),
        reducer: { ProductFeature() }
      )
  )
}
