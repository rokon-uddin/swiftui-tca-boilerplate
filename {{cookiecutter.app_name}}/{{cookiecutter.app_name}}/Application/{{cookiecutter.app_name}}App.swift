//
//  MainApp.swift
//  {{cookiecutter.app_name}}
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import ComposableArchitecture
import Product
import SwiftUI

// MARK: To run the boilerplate on local machine. Please rename '{{cookiecutter.app_name}}App' to any suitable name e.g 'HelloWordApp' to avoid build error.

@main
struct {{cookiecutter.app_name}}App: App {
    var body: some Scene {
      let store = Store(
        initialState: ProductFeature.State(),
        reducer: { ProductFeature() }
      )

      WindowGroup {
          ProductView(store: store)
      }
    }
}
