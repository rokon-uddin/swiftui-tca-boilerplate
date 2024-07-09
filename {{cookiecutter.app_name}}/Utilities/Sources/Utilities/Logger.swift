//
//  VerbosePlugin.swift
//  NetworkPlatform
//
//  Created by {{ cookiecutter.creator }} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Foundation

public enum Logger {

  private static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
  }()

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
    _ messages: Any?..., state: String, file: String, function: String,
    line: Int
  ) {
    #if RELEASE
      return
    #endif

    let dateString = dateFormatter.string(from: Date())
    print(
      "\(dateString) - \(state) \(sourceFileName(file)).\(function):\(line)",
      messages)

  }

  private static func sourceFileName(_ filePath: String) -> String {
    let components = filePath.components(separatedBy: "/")
    return components.isEmpty ? "" : (components.last ?? "")
  }
}
