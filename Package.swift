// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Promotable",
  platforms: [
    .iOS(.v17),
    .macOS(.v14)
  ],
  products: [
    .library(
      name: "Promotable",
      targets: ["Promotable"]),
  ],
  targets: [
    .target(
      name: "Promotable",
      resources: [
        .process("Examples/CampaignsSample.json")
      ]
    ),
    .testTarget(
      name: "PromotableTests",
      dependencies: ["Promotable"]
    ),
  ]
)
