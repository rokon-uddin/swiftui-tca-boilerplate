//
//  AuthEndpoint.swift
//  NetworkPlatform
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Foundation

enum AuthEndpoint: Endpoint {
  case accessToken

  var baseURL: URL {
    URL(string: "https://api.punkapi.com/v2/token")!
  }

  var path: String {
    switch self {
    case .accessToken: "/access_token"
    }
  }

  var method: HTTPMethod {
    .get
  }

  var stubFileName: String? {
    switch self {
    case .accessToken: "AccessToken"
    }
  }
}

struct AccessTokenResponse: Decodable, Sendable {
  let accessToken: String
}
