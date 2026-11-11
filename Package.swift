// swift-tools-version: 6.1
import PackageDescription

// Each engine is a framework of its own, named BareKit like the others, of which
// the traits link one. Local builds use the framework of whichever engine they
// built.
func framework(_ name: String, asset: String, checksum: String) -> Target {
  Context.environment["BARE_KIT_LOCAL"] == nil
    ? .binaryTarget(
      name: name,
      url: "https://github.com/holepunchto/bare-kit-swift/releases/download/v2.2.0/\(asset)",
      checksum: checksum
    )
    : .binaryTarget(name: name, path: "BareKit.xcframework")
}

let package = Package(
  name: "BareKit",
  platforms: [.macOS(.v13), .iOS(.v15)],
  products: [
    .library(name: "BareKit", targets: ["BareKit"])
  ],
  traits: [
    .default(enabledTraits: ["V8"]),
    .trait(name: "V8", description: "Run worklets with V8"),
    .trait(
      name: "JavaScriptCore",
      description: "Run worklets with the JavaScriptCore of the system, in place of V8"
    ),
  ],
  targets: [
    framework(
      "BareKitFramework",
      asset: "BareKit.xcframework.zip",
      checksum: "b902db426fd9ed1bc1c73cc5048a9a9f22799dc0972f2e0c70fab3d6561fb3e2"
    ),
    framework(
      "BareKitJavaScriptCoreFramework",
      asset: "BareKit.JavaScriptCore.xcframework.zip",
      checksum: "0000000000000000000000000000000000000000000000000000000000000000"
    ),
    .target(
      name: "BareKitBridge",
      dependencies: [
        .target(name: "BareKitFramework", condition: .when(traits: ["V8"])),
        .target(
          name: "BareKitJavaScriptCoreFramework",
          condition: .when(traits: ["JavaScriptCore"])
        ),
      ]
    ),
    .target(name: "BareKit", dependencies: ["BareKitBridge"]),
    .testTarget(
      name: "BareKitTests",
      dependencies: ["BareKit"],
      exclude: ["Fixtures"]
    ),
  ]
)
