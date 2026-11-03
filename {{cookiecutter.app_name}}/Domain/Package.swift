// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Domain",
  platforms: [.macOS(.v14), .iOS(.v17)],
  products: [
    .library(
      name: "Domain",
      targets: ["Domain"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "Domain",
      dependencies: []),
    .testTarget(
      name: "DomainTests",
      dependencies: ["Domain"]),
  ]
)
