//
//  NetworkActivity.swift
//  Domain
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Foundation

/// A lifecycle event emitted by the network layer for every request.
public enum NetworkActivity: Equatable, Sendable {
  case started(id: UUID, path: String)
  case finished(id: UUID, statusCode: Int)
  case failed(id: UUID, message: String)

  public var id: UUID {
    switch self {
    case let .started(id, _), let .finished(id, _), let .failed(id, _):
      id
    }
  }
}
