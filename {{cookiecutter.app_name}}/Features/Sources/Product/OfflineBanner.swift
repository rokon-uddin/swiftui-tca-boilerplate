//
//  OfflineBanner.swift
//  Features
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import SwiftUI

struct OfflineBanner: View {
  var body: some View {
    Label("You're offline", systemImage: "wifi.slash")
      .font(.footnote.weight(.semibold))
      .foregroundStyle(.white)
      .frame(maxWidth: .infinity)
      .padding(8)
      .background(.red)
  }
}

#Preview {
  OfflineBanner()
}
