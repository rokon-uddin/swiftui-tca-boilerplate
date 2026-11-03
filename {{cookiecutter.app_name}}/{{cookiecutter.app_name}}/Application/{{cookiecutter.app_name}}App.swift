//
//  {{cookiecutter.app_name}}App.swift
//  {{cookiecutter.app_name}}
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import ComposableArchitecture
import Product
import SwiftUI

@main
struct {{cookiecutter.app_name}}App: App {
  /// Created once for the app's lifetime. Building it inside `body` would recreate
  /// the store, and lose its state, every time the scene is re-evaluated.
  @MainActor static let store = Store(initialState: ProductFeature.State()) {
    ProductFeature()
  }

  var body: some Scene {
    WindowGroup {
      ProductView(store: Self.store)
    }
  }
}
