import BareKitBridge
import Foundation

public struct Worklet {
  public struct Configuration {
    var memoryLimit: UInt
    var assets: String?

    public init(memoryLimit: UInt = 0, assets: String? = nil) {
      self.memoryLimit = memoryLimit
      self.assets = assets
    }
  }

  let worklet: BareWorklet

  public init?() {
    if let worklet = BareWorklet(configuration: nil) {
      self.worklet = worklet
    } else {
      return nil
    }
  }

  public init?(configuration: Configuration) {
    let copy = BareWorkletConfiguration()

    copy.memoryLimit = configuration.memoryLimit
    copy.assets = configuration.assets

    if let worklet = BareWorklet(configuration: copy) {
      self.worklet = worklet
    } else {
      return nil
    }
  }

  public func start(
    filename: String, source: Data, arguments: [String] = []
  ) {
    worklet.start(
      filename, source: source, arguments: arguments
    )
  }

  public func start(
    filename: String, source: String, encoding: String.Encoding, arguments: [String] = []
  ) {
    worklet.start(
      filename, source: source, encoding: encoding.rawValue, arguments: arguments
    )
  }

  public func start(
    name: String, ofType: String, arguments: [String] = []
  ) {
    worklet.start(
      name, ofType: ofType, arguments: arguments
    )
  }

  public func start(
    name: String, ofType: String, inBundle: Bundle, arguments: [String] = []
  ) {
    worklet.start(
      name, ofType: ofType, in: inBundle, arguments: arguments
    )
  }

  public func start(
    name: String, ofType: String, inDirectory: String, arguments: [String] = []
  ) {
    worklet.start(
      name, ofType: ofType, inDirectory: inDirectory, arguments: arguments
    )
  }

  public func start(
    name: String, ofType: String, inDirectory: String, inBundle: Bundle, arguments: [String] = []
  ) {
    worklet.start(
      name, ofType: ofType, inDirectory: inDirectory, in: inBundle, arguments: arguments
    )
  }

  public func suspend() {
    worklet.suspend()
  }

  public func suspend(linger: Int32) {
    worklet.suspend(withLinger: linger)
  }

  public func resume() {
    worklet.resume()
  }

  public func terminate() {
    worklet.terminate()
  }

  public func push(
    data: Data, queue: OperationQueue
  ) async throws -> Data? {
    return try await worklet.push(data, queue: queue)
  }

  public func push(
    data: Data
  ) async throws -> Data? {
    return try await worklet.push(data)
  }

  public func push(
    data: String, encoding: String.Encoding, queue: OperationQueue
  ) async throws -> String? {
    return try await worklet.push(data, encoding: encoding.rawValue, queue: queue)
  }

  public func push(
    data: String, encoding: String.Encoding
  ) async throws -> String? {
    return try await worklet.push(data, encoding: encoding.rawValue)
  }
}

public struct IPC: AsyncSequence {
  let ipc: BareIPC

  public init?(worklet: Worklet) {
    if let ipc = BareIPC(worklet: worklet.worklet) {
      self.ipc = ipc
    } else {
      return nil
    }
  }

  public func read() async -> Data {
    if let data = ipc.read() {
      return data
    }

    assert(ipc.readable == nil)

    return await withCheckedContinuation { continuation in
      ipc.readable = { ipc in
        if let data = ipc.read() {
          ipc.readable = nil

          continuation.resume(returning: data)
        }
      }
    }
  }

  public func read(encoding: String.Encoding) async -> String {
    return String(data: await read(), encoding: encoding)!
  }

  public func write(data: Data) async {
    if ipc.write(data) {
      return
    }

    return await withCheckedContinuation { continuation in
      ipc.writable = { ipc in
        if ipc.write(data) {
          ipc.writable = nil

          continuation.resume()
        }
      }
    }
  }

  public func write(data: String, encoding: String.Encoding) async {
    return await write(data: data.data(using: encoding)!)
  }

  public func close() {
    ipc.close()
  }

  public typealias Element = Data

  public struct AsyncIterator: AsyncIteratorProtocol {
    let ipc: IPC

    public func next() async -> Data? {
      return await ipc.read()
    }
  }

  public func makeAsyncIterator() -> AsyncIterator {
    return AsyncIterator(ipc: self)
  }
}
