# bare-kit-swift

Swift bindings for [Bare Kit](https://github.com/holepunchto/bare-kit), which runs Bare in a thread of its own within the application, known as a worklet, with an IPC to it exposed as `Bare.IPC` inside the worklet.

## Installation

```swift
dependencies: [
  .package(url: "https://github.com/holepunchto/bare-kit-swift", from: "2.0.0")
]
```

Then add `BareKit` to the dependencies of your target:

```swift
.product(name: "BareKit", package: "bare-kit-swift")
```

Bare Kit is available for macOS 13 and later on arm64 and x64, and for iOS 15 and later on devices and simulators.

## Usage

```swift
import BareKit
import Foundation

let worklet = try Worklet()
let ipc = try IPC(worklet: worklet)

try worklet.start(Bundle.main.url(forResource: "app", withExtension: "bundle")!)

try await ipc.write(Data("Hello world".utf8))

for await data in ipc {
  print(String(decoding: data, as: UTF8.self))
}

ipc.close()

await worklet.wait()
```

Where `app.bundle` is a Bare bundle using `Bare.IPC`:

```js
Bare.IPC.on("data", (data) => Bare.IPC.end(data));
```

Releasing a worklet terminates it, so keep a reference to it for as long as it should run. Native addons linked with <https://github.com/holepunchto/bare-link> are loaded by the system linker, so embed them in the application as you would any other framework.

## Release

1. Run the Prebuild workflow with the tag of the release, such as `v2.0.0`. It compiles the framework for every platform and creates a draft release with the XCFramework, whose SHA-256 digest the release lists.
2. Update the URL and checksum of the `BareKitFramework` binary target in `Package.swift` as part of the release.
3. Push the tag. The Publish workflow checks that `Package.swift` declares the checksum of the XCFramework of the draft release and publishes it.

## License

Apache-2.0
