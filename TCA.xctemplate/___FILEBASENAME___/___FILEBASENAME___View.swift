//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

import Common
import ComposableArchitecture
import SwiftUI

public struct ___VARIABLE_moduleName___View: View {
  @Bindable var store: StoreOf<___VARIABLE_moduleName___Feature>

  public init(store: StoreOf<___VARIABLE_moduleName___Feature>) {
    self.store = store
  }

  public var body: some View {
    Text("Hello World!!!")
      .task {
        await store.send(.view(.task)).finish()
      }
  }
}
