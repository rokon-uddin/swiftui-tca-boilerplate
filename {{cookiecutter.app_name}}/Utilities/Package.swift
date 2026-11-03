// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Utilities",
  platforms: [.macOS(.v14), .iOS(.v17)],
  products: [
    .library(
      name: "Utilities",
      targets: ["Utilities"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "Utilities",
      dependencies: []),
    .testTarget(
      name: "UtilitiesTests",
      dependencies: ["Utilities"]),
  ]
)
