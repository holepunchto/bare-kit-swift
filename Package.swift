// swift-tools-version: 6.1
import PackageDescription

// Each engine is a framework of its own, named BareKit like the others, of which
// the traits link one. Local builds use the framework of whichever engine they
// built.
func framework(_ name: String, asset: String, checksum: String) -> Target {
  Context.environment["BARE_KIT_LOCAL"] == nil
    ? .binaryTarget(
      name: name,
      url: "https://github.com/holepunchto/bare-kit-swift/releases/download/v2.5.0/\(asset)",
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
      checksum: "f99ae9608ca517fed466672a3f6188c554a40f878087c12e1c05a6fad95d7a2b"
    ),
    framework(
      "BareKitJavaScriptCoreFramework",
      asset: "BareKit.JavaScriptCore.xcframework.zip",
      checksum: "b36196c750487a82d12ed253aa9ace4fe312053b1715e3d3b2dd579253eebb27"
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
