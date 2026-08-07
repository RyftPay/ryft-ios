import XCTest
import RyftCore

@testable import RyftUI

final class RyftThreeDsActionHandlerTests: XCTestCase {

    private let productionDirectoryServerIds = [
        "visa": "A000000003",
        "mastercard": "A000000004",
        "amex": "A000000025",
        "discover": "A000000152",
        "jcb": "A000000065",
        "unionpay": "A000000333"
    ]

    func test_toDirectoryServerId_shouldReturnMockDirectoryServer_whenSandbox() throws {
        let handler = DefaultRyftThreeDsActionHandler(environment: .sandbox)

        for scheme in productionDirectoryServerIds.keys {
            XCTAssertEqual("M000000003", try handler.toDirectoryServerId(scheme: scheme))
        }
    }

    func test_toDirectoryServerId_shouldReturnMockDirectoryServer_whenSandboxAndSchemeUnsupported() throws {
        let handler = DefaultRyftThreeDsActionHandler(environment: .sandbox)

        XCTAssertEqual("M000000003", try handler.toDirectoryServerId(scheme: "diners"))
    }

    func test_toDirectoryServerId_shouldReturnSchemeDirectoryServer_whenProduction() throws {
        let handler = DefaultRyftThreeDsActionHandler(environment: .production)

        for (scheme, expected) in productionDirectoryServerIds {
            XCTAssertEqual(expected, try handler.toDirectoryServerId(scheme: scheme))
        }
    }

    func test_toDirectoryServerId_shouldIgnoreSchemeCasing_whenProduction() throws {
        let handler = DefaultRyftThreeDsActionHandler(environment: .production)

        XCTAssertEqual("A000000003", try handler.toDirectoryServerId(scheme: "VISA"))
        XCTAssertEqual("A000000004", try handler.toDirectoryServerId(scheme: "MasterCard"))
    }

    func test_toDirectoryServerId_shouldThrowUnsupportedScheme_whenProductionAndSchemeUnsupported() {
        let handler = DefaultRyftThreeDsActionHandler(environment: .production)

        XCTAssertThrowsError(try handler.toDirectoryServerId(scheme: "diners")) { error in
            guard case RavelinThreeDsError.unsupportedScheme(let scheme) = error else {
                XCTFail("expected unsupportedScheme but got \(error)")
                return
            }
            XCTAssertEqual("diners", scheme)
        }
    }
}
