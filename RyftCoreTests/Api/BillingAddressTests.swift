import XCTest
import PassKit

@testable import RyftCore

class BillingAddressTests: XCTestCase {

    private lazy var pkPerson: PersonNameComponents = {
        var person = PersonNameComponents()
        person.givenName = "Nathan"
        person.familyName = "Drake"
        person.nickname = "Nate"
        return person
    }()

    func test_initFromPKContact_shouldReturnNil_whenPostalAddressIsMissing() {
        let contact = PKContact()
        contact.name = pkPerson
        XCTAssertNil(BillingAddress(pkContact: contact))
    }

    func test_initFromPKContact_shouldReturnExpectedResult_whenPostalAddressIsPresent() {
        let contact = PKContact()
        let cnAddress = CNMutablePostalAddress()
        cnAddress.isoCountryCode = "US"
        cnAddress.postalCode = "94043"
        contact.name = nil
        contact.postalAddress = cnAddress
        guard let billingAddress = BillingAddress(pkContact: contact) else {
            XCTFail("expected non-nil billingAddress from PKContact \(contact)")
            return
        }
        let expected = BillingAddress(
            firstName: nil,
            lastName: nil,
            lineOne: nil,
            lineTwo: nil,
            city: nil,
            country: "US",
            postalCode: "94043",
            region: nil
        )
        XCTAssertEqual(expected, billingAddress)
    }

    func test_initFromPKContact_shouldReturnExpectedResult_whenPersonHasBlankName() {
        var person = pkPerson
        person.givenName = ""
        person.familyName = ""
        let contact = PKContact()
        let cnAddress = CNMutablePostalAddress()
        cnAddress.isoCountryCode = "US"
        cnAddress.postalCode = "94043"
        contact.name = person
        contact.postalAddress = cnAddress
        guard let billingAddress = BillingAddress(pkContact: contact) else {
            XCTFail("expected non-nil billingAddress from PKContact \(contact)")
            return
        }
        let expected = BillingAddress(
            firstName: nil,
            lastName: nil,
            lineOne: nil,
            lineTwo: nil,
            city: nil,
            country: "US",
            postalCode: "94043",
            region: nil
        )
        XCTAssertEqual(expected, billingAddress)
    }

    func test_initFromPKContact_shouldReturnExpectedResult_whenPostalAddressAndPersonArePresent() {
        let contact = PKContact()
        let cnAddress = CNMutablePostalAddress()
        cnAddress.isoCountryCode = "US"
        cnAddress.postalCode = "94043"
        contact.name = pkPerson
        contact.postalAddress = cnAddress
        guard let billingAddress = BillingAddress(pkContact: contact) else {
            XCTFail("expected non-nil billingAddress from PKContact \(contact)")
            return
        }
        let expected = BillingAddress(
            firstName: pkPerson.givenName,
            lastName: pkPerson.familyName,
            lineOne: nil,
            lineTwo: nil,
            city: nil,
            country: "US",
            postalCode: "94043",
            region: nil
        )
        XCTAssertEqual(expected, billingAddress)
    }

    func test_toRyftBillingAddress_shouldReturnExpectedResult_whenPostalAddressContainsAllFields() {
        let contact = PKContact()
        let cnAddress = CNMutablePostalAddress()
        cnAddress.street = "c/o Google LLC"
        cnAddress.isoCountryCode = "US"
        cnAddress.postalCode = "94043"
        cnAddress.city = "Libertalia"
        cnAddress.state = "CA"
        contact.name = pkPerson
        contact.postalAddress = cnAddress
        guard let billingAddress = BillingAddress(pkContact: contact) else {
            XCTFail("expected non-nil billingAddress from PKContact \(contact)")
            return
        }
        let expected = BillingAddress(
            firstName: "Nathan",
            lastName: "Drake",
            lineOne: "c/o Google LLC",
            lineTwo: nil,
            city: "Libertalia",
            country: "US",
            postalCode: "94043",
            region: "CA"
        )
        XCTAssertEqual(expected, billingAddress)
    }

    func test_toJson_shouldReturnExpectedValue_whenNilFieldsAreMissing() {
        let billingAddress = TestFixtures.billingAddress()
        let result = billingAddress.toJson()
        XCTAssertNil(result["firstName"])
        XCTAssertNil(result["lastName"])
        XCTAssertNil(result["lineOne"])
        XCTAssertNil(result["lineTwo"])
        XCTAssertNil(result["city"])
        XCTAssertNil(result["region"])
        guard let country = result["country"] as? String else {
            XCTFail("serialized JSON country field was not expected type")
            return
        }
        guard let postalCode = result["postalCode"] as? String else {
            XCTFail("serialized JSON postalCode field was not expected type")
            return
        }
        XCTAssertEqual("US", country)
        XCTAssertEqual("94043", postalCode)
    }

    // swiftlint:disable function_body_length
    func test_toJson_shouldReturnExpectedValue_whenNilFieldsArePresent() {
        let billingAddress = BillingAddress(
            firstName: "John",
            lastName: "Doe",
            lineOne: "c/o Google LLC",
            lineTwo: "1600 Amphitheatre Pkwy",
            city: "Mountain View",
            country: "US",
            postalCode: "94043",
            region: "CA"
        )
        let result = billingAddress.toJson()
        XCTAssertNotNil(result["firstName"])
        XCTAssertNotNil(result["lastName"])
        XCTAssertNotNil(result["lineOne"])
        XCTAssertNotNil(result["lineTwo"])
        XCTAssertNotNil(result["city"])
        XCTAssertNotNil(result["region"])
        guard let firstName = result["firstName"] as? String else {
            XCTFail("serialized JSON firstName field was not expected type")
            return
        }
        guard let lastName = result["lastName"] as? String else {
            XCTFail("serialized JSON lastName field was not expected type")
            return
        }
        guard let lineOne = result["lineOne"] as? String else {
            XCTFail("serialized JSON lineOne field was not expected type")
            return
        }
        guard let lineTwo = result["lineTwo"] as? String else {
            XCTFail("serialized JSON lineTwo field was not expected type")
            return
        }
        guard let city = result["city"] as? String else {
            XCTFail("serialized JSON city field was not expected type")
            return
        }
        guard let country = result["country"] as? String else {
            XCTFail("serialized JSON country field was not expected type")
            return
        }
        guard let postalCode = result["postalCode"] as? String else {
            XCTFail("serialized JSON postalCode field was not expected type")
            return
        }
        guard let region = result["region"] as? String else {
            XCTFail("serialized JSON region field was not expected type")
            return
        }
        XCTAssertEqual("John", firstName)
        XCTAssertEqual("Doe", lastName)
        XCTAssertEqual("c/o Google LLC", lineOne)
        XCTAssertEqual("1600 Amphitheatre Pkwy", lineTwo)
        XCTAssertEqual("Mountain View", city)
        XCTAssertEqual("US", country)
        XCTAssertEqual("94043", postalCode)
        XCTAssertEqual("CA", region)
    }
    // swiftlint:enable function_body_length
}
