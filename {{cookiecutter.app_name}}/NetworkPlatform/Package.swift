// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "NetworkPlatform",
  platforms: [.macOS(.v14), .iOS(.v17)],
  products: [
    .library(
      name: "NetworkPlatform",
      targets: ["NetworkPlatform"])
  ],

  dependencies: [
    .package(path: "../Domain"),
    .package(path: "../Utilities"),
  ],

  targets: [
    .target(
      name: "BuildConfiguration",
      dependencies: []),

    .target(
      name: "NetworkPlatform",
      dependencies: [
        "BuildConfiguration",
        .product(name: "Domain", package: "Domain"),
        .product(name: "Utilities", package: "Utilities"),
      ],
      resources: [
        .copy("Resources/StubbedResponse/Product.json")
      ]
    ),

    .testTarget(
      name: "NetworkPlatformTests",
      dependencies: ["NetworkPlatform"]
    ),
  ]
)
