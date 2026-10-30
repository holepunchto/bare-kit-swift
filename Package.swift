// swift-tools-version: 5.10
import PackageDescription

let framework: Target =
  Context.environment["BARE_KIT_LOCAL"] == nil
  ? .binaryTarget(
    name: "BareKitFramework",
    url:
      "https://github.com/holepunchto/bare-kit-swift/releases/download/v2.0.0/BareKit.xcframework.zip",
    checksum: "a605f33fed5f704c504342815c0f0b0c70c1f5f70477ab94ae2396051a58a464"
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
