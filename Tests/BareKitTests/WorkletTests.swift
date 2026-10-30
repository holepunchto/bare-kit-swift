import BareKit
import Foundation
import XCTest

let fixtures = URL(fileURLWithPath: #filePath)
  .deletingLastPathComponent()
  .appendingPathComponent("Fixtures")

func fixture(_ name: String) -> URL {
  fixtures.appendingPathComponent(name)
}

func readAll(_ ipc: IPC) async -> String {
  var received = Data()

  for await data in ipc {
    received.append(data)
  }

  return String(decoding: received, as: UTF8.self)
}

final class WorkletTests: XCTestCase {
  func testEchoesIPCData() async throws {
    let worklet = try Worklet()
    let ipc = try IPC(worklet: worklet)

    try worklet.start(fixture("echo.js"))

    try await ipc.write(Data("Hello world".utf8))

    let received = await readAll(ipc)
    XCTAssertEqual(received, "Hello world")

    ipc.close()

    let code = await worklet.wait()
    XCTAssertEqual(code, 0)
  }

  func testEndsIPCData() async throws {
    let worklet = try Worklet()
    let ipc = try IPC(worklet: worklet)

    try worklet.start(fixture("collect.js"))

    try await ipc.write(Data("Hello ".utf8))
    try await ipc.write(Data("world".utf8))

    ipc.end()

    do {
      try await ipc.write(Data("!".utf8))
      XCTFail("Expected the write to fail")
    } catch {
      XCTAssertEqual(error as? BareKitError, .closed)
    }

    let received = await readAll(ipc)
    XCTAssertEqual(received, "Hello world")

    let code = await worklet.wait()
    XCTAssertEqual(code, 0)
  }

  func testPassesArguments() async throws {
    let worklet = try Worklet()
    let ipc = try IPC(worklet: worklet)

    try worklet.start(fixture("argv.js"), arguments: ["foo", "bar"])

    let received = await readAll(ipc)
    XCTAssertEqual(received, #"["foo","bar"]"#)

    ipc.close()
  }

  func testRunsSource() async throws {
    let worklet = try Worklet()
    let ipc = try IPC(worklet: worklet)

    try worklet.start("/app.js", source: Data("Bare.IPC.end('Hello world')".utf8))

    let received = await readAll(ipc)
    XCTAssertEqual(received, "Hello world")

    ipc.close()
  }

  func testReportsTheExitCode() async throws {
    let worklet = try Worklet()

    try worklet.start(fixture("exit.js"))

    let code = await worklet.wait()
    XCTAssertEqual(code, 3)
  }

  func testTerminates() async throws {
    let worklet = try Worklet()
    let ipc = try IPC(worklet: worklet)

    try worklet.start(fixture("echo.js"))

    worklet.terminate()

    await worklet.wait()

    let received = await readAll(ipc)
    XCTAssertEqual(received, "")
  }

  func testFailsToWriteOnceClosed() async throws {
    let worklet = try Worklet()
    let ipc = try IPC(worklet: worklet)

    try worklet.start(fixture("echo.js"))

    ipc.close()

    do {
      try await ipc.write(Data("Hello world".utf8))
      XCTFail("Expected the write to fail")
    } catch {
      XCTAssertEqual(error as? BareKitError, .closed)
    }
  }
}
