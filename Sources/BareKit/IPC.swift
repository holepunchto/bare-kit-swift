import BareKitBridge
import Foundation

public struct IPC: AsyncSequence {
  let ipc: BareIPC

  public init(worklet: Worklet) {
    self.ipc = BareIPC(worklet: worklet.worklet)!
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

