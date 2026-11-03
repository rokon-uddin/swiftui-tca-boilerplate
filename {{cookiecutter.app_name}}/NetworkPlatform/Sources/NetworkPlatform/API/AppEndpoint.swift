//
//  AppEndpoint.swift
//  NetworkPlatform
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Foundation

enum AppEndpoint: Endpoint {
  case product(id: Int)

  var baseURL: URL {
    URL(string: "https://fakestoreapi.com")!
  }

  var path: String {
    switch self {
    case let .product(id): "/products/\(id)"
    }
  }

  var method: HTTPMethod {
    switch self {
    case .product: .get
    }
  }

  var stubFileName: String? {
    switch self {
    case .product: "Product"
    }
  }
}
