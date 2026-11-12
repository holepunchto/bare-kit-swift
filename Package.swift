// swift-tools-version: 6.1
import PackageDescription

// Each engine is a framework of its own, named BareKit like the others, of which
// the traits link one. Local builds use the framework of whichever engine they
// built.
func framework(_ name: String, asset: String, checksum: String) -> Target {
  Context.environment["BARE_KIT_LOCAL"] == nil
    ? .binaryTarget(
      name: name,
      url: "https://github.com/holepunchto/bare-kit-swift/releases/download/v2.4.0/\(asset)",
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
      checksum: "4235e864c74cb66709c3a8de8e68995b03996eb5a0900376fbf947e13e38c97b"
    ),
    framework(
      "BareKitJavaScriptCoreFramework",
      asset: "BareKit.JavaScriptCore.xcframework.zip",
      checksum: "abdd6bc08cafa2774659c8b50f3d57a657dbc2e2bd7ecb4bdff55bc7255fb2ca"
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
