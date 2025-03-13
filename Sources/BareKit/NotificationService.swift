import BareKitBridge
import Foundation
import UserNotifications

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

  open func workletDidReply(_ reply: [AnyHashable: Any]) -> UNNotificationContent {
    return service.workletDidReply(reply)
  }
}
