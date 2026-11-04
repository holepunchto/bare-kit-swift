// swift-tools-version: 5.10
import PackageDescription

let framework: Target =
  Context.environment["BARE_KIT_LOCAL"] == nil
  ? .binaryTarget(
    name: "BareKitFramework",
    url:
      "https://github.com/holepunchto/bare-kit-swift/releases/download/v2.2.0/BareKit.xcframework.zip",
    checksum: "b902db426fd9ed1bc1c73cc5048a9a9f22799dc0972f2e0c70fab3d6561fb3e2"
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
