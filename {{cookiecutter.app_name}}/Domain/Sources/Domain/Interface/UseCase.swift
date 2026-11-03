//
//  UseCase.swift
//  Domain
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Foundation

public protocol UseCase<Input, Output>: Sendable {
  associatedtype Input
  associatedtype Output

  func callAsFunction(input: Input) async throws -> Output
}

extension UseCase where Input == Void {
  public func callAsFunction() async throws -> Output {
    try await callAsFunction(input: ())
  }
}

/// A use case that produces a long-lived stream of values.
public protocol StreamUseCase<Input, Element>: Sendable {
  associatedtype Input
  associatedtype Element: Sendable

  func callAsFunction(input: Input) async -> AsyncStream<Element>
}

extension StreamUseCase where Input == Void {
  public func callAsFunction() async -> AsyncStream<Element> {
    await callAsFunction(input: ())
  }
}
