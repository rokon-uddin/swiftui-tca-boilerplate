// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Features",
  platforms: [.macOS(.v14), .iOS(.v17)],
  products: [
    .library(
      name: "Product",
      targets: ["Product"]
    ),

    .library(
      name: "Counter",
      targets: ["Counter"]
    ),
  ],
  dependencies: [
    .package(path: "../Common"),
    .package(path: "../Domain"),
    .package(path: "../NetworkPlatform"),
    .package(path: "../PersistentPlatform"),
    .package(path: "../Utilities"),
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      from: "1.26.2"
    ),
  ],
  targets: [
    .target(
      name: "Product",
      dependencies: [
        "Counter",
        .product(name: "Common", package: "Common"),
        .product(name: "Domain", package: "Domain"),
        .product(name: "NetworkPlatform", package: "NetworkPlatform"),
        .product(name: "PersistentPlatform", package: "PersistentPlatform"),
        .product(name: "Utilities", package: "Utilities"),
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"),
      ]
    ),

    .target(
      name: "Counter",
      dependencies: [
        .product(name: "Common", package: "Common"),
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"),
      ]
    ),

    .testTarget(
      name: "FeaturesTests",
      dependencies: [
        "Counter",
        "Product",
        .product(name: "Domain", package: "Domain"),
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"),
      ]
    ),
  ]
)
