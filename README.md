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
Bare.IPC.on('data', (data) => Bare.IPC.end(data))
```

Iterating the IPC yields the data that the worklet writes to `Bare.IPC` until it ends its side. As `Bare.IPC` keeps the worklet alive, `end()` ends the data sent to it so that it may exit on its own, and `wait()` returns its exit code. Writes fail with `BareKitError.closed` once the IPC is ended or closed, and with `BareKitError.peerClosed` once the worklet has closed its side. Releasing a worklet terminates it, so keep a reference to it for as long as it should run.

These bindings are a thin layer over [Bare Kit](https://github.com/holepunchto/bare-kit), whose README covers the [lifecycle](https://github.com/holepunchto/bare-kit#lifecycle), [IPC](https://github.com/holepunchto/bare-kit#ipc), [suspension](https://github.com/holepunchto/bare-kit#suspension), [addons](https://github.com/holepunchto/bare-kit#addons), and [error handling](https://github.com/holepunchto/bare-kit#error-handling) of a worklet. In Swift terms:

- If `source` is `nil`, `start()` reads the module at runtime, so the worklet may be a module next to its `node_modules` rather than a bundle.
- Bare Kit is a dynamic framework, so native addons resolve the symbols of Bare from it as is.
- Bare Kit calls back on threads of its own, which the bindings turn into async results, so a worklet and its IPC may be used from any task.
- An uncaught error in the worklet aborts the process, the application included, so report errors over `Bare.IPC` as described in [error handling](https://github.com/holepunchto/bare-kit#error-handling).

## Platforms

The package supports iOS and macOS, and includes Bare Kit as a framework from its release. A relative filename names a resource of the application bundle, which extensions share with their application.

Native addons linked with <https://github.com/holepunchto/bare-link> are loaded by the system linker, so embed them in the application as you would any other framework.

Bare Kit runs worklets with V8 by default. To run them with the JavaScriptCore of the system instead, which leaves V8 out of the application, enable the `JavaScriptCore` trait in place of the default `V8` trait:

```swift
.package(url: "https://github.com/holepunchto/bare-kit-swift", from: "<tag>", traits: ["JavaScriptCore"])
```

Traits apply to the package across the application, so packages that depend on it must agree on the engine. With both traits enabled, the build fails as the two frameworks clash.

## License

Apache-2.0
