// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "promotable-ios-sdk",
  platforms: [
    .iOS(.v17),
    .macOS(.v14)
  ],
  products: [
    .library(
      name: "promotable-ios-sdk",
      targets: ["promotable-ios-sdk"]),
  ],
  targets: [
    .target(
      name: "promotable-ios-sdk",
      resources: [
        .process("Examples/CampaignsSample.json")
      ]
    ),
    .testTarget(
      name: "promotable-ios-sdkTests",
      dependencies: ["promotable-ios-sdk"]
    ),
  ]
)
