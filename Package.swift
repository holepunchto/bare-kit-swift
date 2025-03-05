// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "BareKit",
  platforms: [.macOS(.v11), .iOS(.v14)],
  products: [
    .library(
      name: "BareKit",
      targets: ["BareKit"]
    )
  ],
  targets: [
    .target(
      name: "BareKit",
      dependencies: ["BareKitBridge"]
    ),
    .target(
      name: "BareKitBridge",
      linkerSettings: [
        .linkedFramework("BareKit")
      ]
    ),
  ]
)
