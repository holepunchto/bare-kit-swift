// swift-tools-version: 5.10
import PackageDescription

let framework: Target =
  Context.environment["BARE_KIT_LOCAL"] == nil
  ? .binaryTarget(
    name: "BareKitFramework",
    url:
      "https://github.com/holepunchto/bare-kit-swift/releases/download/v2.1.0/BareKit.xcframework.zip",
    checksum: "08b008abcd30be9821a739f90b363265510b5782fd2c44e198744373ca71a8a8"
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
