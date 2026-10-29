# bare-kit-swift

Swift bindings for [Bare Kit](https://github.com/holepunchto/bare-kit), which runs Bare in a thread of its own within the application, known as a worklet, with an IPC to it exposed as `Bare.IPC` inside the worklet.

```swift
dependencies: [
  .package(url: "https://github.com/holepunchto/bare-kit-swift", from: "<tag>")
]

.product(name: "BareKit", package: "bare-kit-swift")
```

## Usage

```swift
import BareKit
import Foundation

let worklet = try Worklet()
let ipc = try IPC(worklet: worklet)

try worklet.start("app.bundle")

try await ipc.write(Data("Hello world".utf8))

for await data in ipc {
  print(String(decoding: data, as: UTF8.self))
}

ipc.close()

await worklet.wait()
```

Where `app.bundle` is a resource of the application, here a Bare bundle using `Bare.IPC`:

```js
Bare.IPC.on("data", (data) => Bare.IPC.end(data));
```

Releasing a worklet terminates it, so keep a reference to it for as long as it should run. Native addons linked with <https://github.com/holepunchto/bare-link> are loaded by the system linker, so embed them in the application as you would any other framework.

## License

Apache-2.0
