// swift-tools-version: 6.1
import PackageDescription

// Each engine is a framework of its own, named BareKit like the others, of which
// the traits link one. Local builds use the framework of whichever engine they
// built.
func framework(_ name: String, asset: String, checksum: String) -> Target {
  Context.environment["BARE_KIT_LOCAL"] == nil
    ? .binaryTarget(
      name: name,
      url: "https://github.com/holepunchto/bare-kit-swift/releases/download/v2.4.3/\(asset)",
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
      checksum: "b91b1c0b2fdb12d97d70968d94ed64cc92707bb38b9e6da9a13803439f4e6bf5"
    ),
    framework(
      "BareKitJavaScriptCoreFramework",
      asset: "BareKit.JavaScriptCore.xcframework.zip",
      checksum: "c397ea971bed337f8f0c8fbe4d1b1868fd06ce3c9ea5955b4e831d776a77e3f8"
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
