// swift-tools-version: 5.10
import PackageDescription

let framework: Target =
  Context.environment["BARE_KIT_LOCAL"] == nil
  ? .binaryTarget(
    name: "BareKitFramework",
    url:
      "https://github.com/holepunchto/bare-kit-swift/releases/download/v2.3.0/BareKit.xcframework.zip",
    checksum: "4f2244512fb3dd860e3c23d7f6cdf0d6dff97485750df537529cf89242895e3e"
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
