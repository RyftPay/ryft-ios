import XCTest

@testable import RyftCore

final class RyftEnvironmentTests: XCTestCase {

    func test_from_shouldReturnSandboxEnv_whenKeyIsForSandbox() {
        XCTAssertEqual(.sandbox, RyftEnvironment.fromApiKey(publicKey: "pk_sandbox_123456"))
    }

    func test_from_shouldReturnProductionEnv_whenKeyIsForProduction() {
        XCTAssertEqual(.production, RyftEnvironment.fromApiKey(publicKey: "pk_123456"))
    }
}
