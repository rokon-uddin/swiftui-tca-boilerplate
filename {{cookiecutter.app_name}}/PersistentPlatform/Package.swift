// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "PersistentPlatform",
  platforms: [.macOS(.v14), .iOS(.v17)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "PersistentPlatform",
      targets: ["PersistentPlatform"])
  ],
  dependencies: [
    .package(path: "../Domain"),
    .package(path: "../Utilities"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "PersistentPlatform",
      dependencies: [
        .product(name: "Domain", package: "Domain"),
        .product(name: "Utilities", package: "Utilities"),
      ],
      resources: [
        .process("Model.xcdatamodeld")
      ]
    ),
    .testTarget(
      name: "PersistentPlatformTests",
      dependencies: ["PersistentPlatform"]
    ),
  ]
)
