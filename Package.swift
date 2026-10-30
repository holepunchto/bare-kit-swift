// swift-tools-version: 5.10
import PackageDescription

let framework: Target =
  Context.environment["BARE_KIT_LOCAL"] == nil
  ? .binaryTarget(
    name: "BareKitFramework",
    url:
      "https://github.com/holepunchto/bare-kit-swift/releases/download/v2.0.0/BareKit.xcframework.zip",
    checksum: "0000000000000000000000000000000000000000000000000000000000000000"
  )
  : .binaryTarget(name: "BareKitFramework", path: "BareKit.xcframework")

let package = Package(
  name: "BareKit",
  platforms: [.macOS(.v13), .iOS(.v15)],
  products: [
    .library(name: "BareKit", targets: ["BareKit"])
  ],
  targets: [
    framework,
    .target(name: "BareKitBridge", dependencies: ["BareKitFramework"]),
    .target(name: "BareKit", dependencies: ["BareKitBridge"]),
    .testTarget(
      name: "BareKitTests",
      dependencies: ["BareKit"],
      exclude: ["Fixtures"]
    ),
  ]
)
