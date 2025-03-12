import BareKitBridge
import Foundation
import UserNotifications

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

  public init(configuration: Configuration = Configuration()) {
    let copy = BareWorkletConfiguration()

    copy.memoryLimit = configuration.memoryLimit
    copy.assets = configuration.assets

    self.worklet = BareWorklet(configuration: copy)!
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
    name: String, ofType type: String, arguments: [String] = []
  ) {
    worklet.start(
      name, ofType: type, arguments: arguments
    )
  }

  public func start(
    name: String, ofType type: String, inBundle bundle: Bundle, arguments: [String] = []
  ) {
    worklet.start(
      name, ofType: type, in: bundle, arguments: arguments
    )
  }

  public func start(
    name: String, ofType type: String, inDirectory subpath: String, arguments: [String] = []
  ) {
    worklet.start(
      name, ofType: type, inDirectory: subpath, arguments: arguments
    )
  }

  public func start(
    name: String, ofType type: String, inDirectory subpath: String, inBundle bundle: Bundle,
    arguments: [String] = []
  ) {
    worklet.start(
      name, ofType: type, inDirectory: subpath, in: bundle, arguments: arguments
    )
  }

  public func suspend(linger: Int32 = 0) {
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

public typealias NotificationServiceDelegate = BareNotificationServiceDelegate

open class NotificationService: UNNotificationServiceExtension {
  private let service: BareNotificationService

  public var delegate: BareNotificationServiceDelegate? {
    didSet {
      self.service.delegate = delegate ?? self.service
    }
  }

  public override init() {
    self.service = BareNotificationService(configuration: nil)!

    super.init()
  }

  public init(configuration: Worklet.Configuration = Worklet.Configuration()) {
    let copy = BareWorkletConfiguration()

    copy.memoryLimit = configuration.memoryLimit
    copy.assets = configuration.assets

    self.service = BareNotificationService(configuration: copy)!

    super.init()
  }

  public init(
    filename: String, source: Data?, arguments: [String] = [],
    configuration: Worklet.Configuration = Worklet.Configuration()
  ) {
    let copy = BareWorkletConfiguration()

    copy.memoryLimit = configuration.memoryLimit
    copy.assets = configuration.assets

    self.service = BareNotificationService(
      filename: filename, source: source, arguments: arguments, configuration: copy
    )!

    super.init()
  }

  public init(
    filename: String, source: String, encoding: String.Encoding, arguments: [String] = [],
    configuration: Worklet.Configuration = Worklet.Configuration()
  ) {
    let copy = BareWorkletConfiguration()

    copy.memoryLimit = configuration.memoryLimit
    copy.assets = configuration.assets

    self.service = BareNotificationService(
      filename: filename, source: source, encoding: encoding.rawValue, arguments: arguments,
      configuration: copy
    )!

    super.init()
  }

  public init(
    resource: String, ofType type: String, arguments: [String] = [],
    configuration: Worklet.Configuration = Worklet.Configuration()
  ) {
    let copy = BareWorkletConfiguration()

    copy.memoryLimit = configuration.memoryLimit
    copy.assets = configuration.assets

    self.service = BareNotificationService(
      resource: resource, ofType: type, arguments: arguments, configuration: copy
    )!

    super.init()
  }

  public init(
    resource: String, ofType type: String, inBundle bundle: Bundle, arguments: [String] = [],
    configuration: Worklet.Configuration = Worklet.Configuration()
  ) {
    let copy = BareWorkletConfiguration()

    copy.memoryLimit = configuration.memoryLimit
    copy.assets = configuration.assets

    self.service = BareNotificationService(
      resource: resource, ofType: type, in: bundle, arguments: arguments,
      configuration: copy
    )!

    super.init()
  }

  public init(
    resource: String, ofType type: String, inDirectory subpath: String, arguments: [String] = [],
    configuration: Worklet.Configuration = Worklet.Configuration()
  ) {
    let copy = BareWorkletConfiguration()

    copy.memoryLimit = configuration.memoryLimit
    copy.assets = configuration.assets

    self.service = BareNotificationService(
      resource: resource, ofType: type, inDirectory: subpath, arguments: arguments,
      configuration: copy
    )!

    super.init()
  }

  public init(
    resource: String, ofType type: String, inDirectory subpath: String, inBundle bundle: Bundle,
    arguments: [String] = [], configuration: Worklet.Configuration = Worklet.Configuration()
  ) {
    let copy = BareWorkletConfiguration()

    copy.memoryLimit = configuration.memoryLimit
    copy.assets = configuration.assets

    self.service = BareNotificationService(
      resource: resource, ofType: type, inDirectory: subpath, in: bundle, arguments: arguments,
      configuration: copy
    )!

    super.init()
  }

  open override func didReceive(
    _ request: UNNotificationRequest,
    withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
  ) {
    service.didReceive(request, withContentHandler: contentHandler)
  }

  open override func serviceExtensionTimeWillExpire() {
    service.serviceExtensionTimeWillExpire()
  }
}
