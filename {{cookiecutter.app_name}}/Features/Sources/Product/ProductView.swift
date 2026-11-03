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

public struct ProductView: View {
  @Bindable var store: StoreOf<ProductFeature>

  public init(store: StoreOf<ProductFeature>) {
    self.store = store
  }

  public var body: some View {
    VStack(spacing: 0) {
      if !store.isOnline {
        OfflineBanner()
      }

      VStack(spacing: 20) {
        if store.isLoading {
          ProgressView()
        }
        Text(store.product?.title ?? "Unknown")
          .font(.headline)
        Text(store.product?.description ?? "Unknown")
        if let errorMessage = store.errorMessage {
          Text(errorMessage)
            .font(.footnote)
            .foregroundStyle(.red)
        }
      }
      .padding()

      Form {
        Section {
          Button("Save") {
            store.send(.view(.save))
          }
          .disabled(store.product == nil)

          Button("Sheet") {
            store.send(.view(.showSheet))
          }

          Button("Full Screen Cover") {
            store.send(.view(.showFullScreenCover))
          }
        }

        Section("Saved products (\(store.savedProducts.count))") {
          ForEach(store.savedProducts) { product in
            Text(product.title)
          }
        }
      }
    }
    .task {
      await store.send(.view(.task)).finish()
    }
    .sheet(
      item: $store.scope(state: \.destination?.sheet, action: \.destination.sheet)
    ) { store in
      CounterView(store: store)
    }
    .fullScreenCoverIfAvailable(
      item: $store.scope(
        state: \.destination?.fullScreenCover, action: \.destination.fullScreenCover)
    ) { store in
      CounterView(store: store)
    }
  }
}

extension View {
  /// `fullScreenCover` is unavailable on macOS; fall back to a sheet there.
  fileprivate func fullScreenCoverIfAvailable<Item: Identifiable, Content: View>(
    item: Binding<Item?>,
    @ViewBuilder content: @escaping (Item) -> Content
  ) -> some View {
    #if os(iOS)
      fullScreenCover(item: item, content: content)
    #else
      sheet(item: item, content: content)
    #endif
  }
}

#Preview {
  ProductView(
    store: Store(initialState: ProductFeature.State()) {
      ProductFeature()
    }
  )
}
