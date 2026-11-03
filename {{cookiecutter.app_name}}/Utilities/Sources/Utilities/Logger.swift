//
//  Logger.swift
//  Utilities
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Foundation

public enum Logger: Sendable {

  public static func info(
    _ messages: Any?..., file: String = #file, function: String = #function,
    line: Int = #line
  ) {
    printMessage(
      messages, state: "ℹ️ INFO", file: file, function: function, line: line)
  }

  public static func error(
    _ messages: Any?..., file: String = #file, function: String = #function,
    line: Int = #line
  ) {
    printMessage(
      messages, state: "💥 ERROR", file: file, function: function, line: line)
  }

  public static func warning(
    _ messages: Any?..., file: String = #file, function: String = #function,
    line: Int = #line
  ) {
    printMessage(
      messages, state: "⚠️ WARNING", file: file, function: function, line: line)
  }

  public static func success(
    _ messages: Any?..., file: String = #file, function: String = #function,
    line: Int = #line
  ) {
    printMessage(
      messages, state: "✅ SUCCESS", file: file, function: function, line: line)
  }

  private static func printMessage(
    _ messages: [Any?], state: String, file: String, function: String,
    line: Int
  ) {
    #if DEBUG
      let dateString = Date().formatted(
        .iso8601.year().month().day().time(includingFractionalSeconds: false))
      print(
        "\(dateString) - \(state) \(sourceFileName(file)).\(function):\(line)",
        messages.map { $0.map { "\($0)" } ?? "nil" }.joined(separator: " "))
    #endif
  }

  private static func sourceFileName(_ filePath: String) -> String {
    let components = filePath.components(separatedBy: "/")
    return components.isEmpty ? "" : (components.last ?? "")
  }
}
