import XCTest

@testable import RyftCard

final class RyftCardValidationTests: XCTestCase {

    func test_luhnCheck_shouldReturnTrue_forValidVisaCards() {
        TestFixtures.visaCards.forEach {
            XCTAssertTrue(RyftCardValidation.luhnCheck(cardNumber: $0))
        }
    }

    func test_luhnCheck_shouldReturnFalse_forInvalidVisaCards() {
        TestFixtures.invalidVisaCards.forEach {
            XCTAssertFalse(RyftCardValidation.luhnCheck(cardNumber: $0))
        }
    }

    func test_luhnCheck_shouldReturnTrue_forValidMastercardCards() {
        TestFixtures.mastercardCards.forEach {
            XCTAssertTrue(RyftCardValidation.luhnCheck(cardNumber: $0))
        }
    }

    func test_luhnCheck_shouldReturnFalse_forInvalidMastercardCards() {
        TestFixtures.invalidMastercardCards.forEach {
            XCTAssertFalse(RyftCardValidation.luhnCheck(cardNumber: $0))
        }
    }

    func test_luhnCheck_shouldReturnTrue_forValidAmexCards() {
        TestFixtures.amexCards.forEach {
            XCTAssertTrue(RyftCardValidation.luhnCheck(cardNumber: $0))
        }
    }

    func test_luhnCheck_shouldReturnFalse_forInvalidAmexCards() {
        TestFixtures.invalidAmexCards.forEach {
            XCTAssertFalse(RyftCardValidation.luhnCheck(cardNumber: $0))
        }
    }

    func test_determineCardType_shouldReturnUnknown_whenGivenNilValue() {
        XCTAssertEqual(
            RyftCardType.unknown,
            RyftCardValidation.determineCardType(cardNumber: nil)
        )
    }

    func test_determineCardType_shouldReturnUnknown_whenGivenNonNumericValue() {
        XCTAssertEqual(
            RyftCardType.unknown,
            RyftCardValidation.determineCardType(cardNumber: "abc12")
        )
    }

    func test_determineCardType_shouldReturnVisa_whenGivenVisaCards() {
        TestFixtures.visaCards.forEach {
            XCTAssertEqual(
                RyftCardType.visa,
                RyftCardValidation.determineCardType(cardNumber: $0)
            )
        }
    }

    func test_determineCardType_shouldReturnMastercard_whenGivenMastercardCards() {
        TestFixtures.mastercardCards.forEach {
            XCTAssertEqual(
                RyftCardType.mastercard,
                RyftCardValidation.determineCardType(cardNumber: $0)
            )
        }
    }

    func test_determineCardType_shouldReturnAmex_whenGivenAmexCards() {
        TestFixtures.amexCards.forEach {
            XCTAssertEqual(
                RyftCardType.amex,
                RyftCardValidation.determineCardType(cardNumber: $0)
            )
        }
    }

    func test_validateCardNumber_shouldReturnIncomplete_whenValueIsEmpty() {
        XCTAssertEqual(
            RyftInputValidationState.incomplete,
            RyftCardValidation.validate(cardNumber: "", with: .visa)
        )
    }

    func test_validateCardNumber_shouldReturnInvalid_whenCardTypeIsUnknown() {
        XCTAssertEqual(
            RyftInputValidationState.invalid,
            RyftCardValidation.validate(cardNumber: "44", with: .unknown)
        )
    }

    func test_validateCardNumber_shouldReturnIncomplete_whenValueIsValidButTooShort() {
        XCTAssertEqual(
            RyftInputValidationState.incomplete,
            RyftCardValidation.validate(cardNumber: "44", with: .visa)
        )
    }

    func test_validateCardNumber_shouldReturnInvalid_whenValueIsTooLongForCardScheme() {
        XCTAssertEqual(
            RyftInputValidationState.invalid,
            RyftCardValidation.validate(cardNumber: "42424242424242424", with: .visa)
        )
    }

    func test_validateCardNumber_shouldReturnInvalid_whenValueIsCorrectLength_butFailsLuhnCheck() {
        let invalidVisaCard = TestFixtures.invalidVisaCards[0]
        XCTAssertEqual(
            RyftInputValidationState.invalid,
            RyftCardValidation.validate(cardNumber: invalidVisaCard, with: .visa)
        )
    }

    func test_validateCardNumber_shouldReturnValid_whenValueIsCorrectLength_andPassesLuhnCheck() {
        let validVisaCard = TestFixtures.visaCards[0]
        XCTAssertEqual(
            RyftInputValidationState.valid,
            RyftCardValidation.validate(cardNumber: validVisaCard, with: .visa)
        )
    }

    func test_validateExpiry_shouldReturnInvalid_whenMonthIsInvalid() {
        let invalidMonths = ["a", "ab", "13", "14", "222"]
        invalidMonths.forEach {
            XCTAssertEqual(
                RyftInputValidationState.invalid,
                RyftCardValidation.validate(expirationMonth: $0, expirationYear: "")
            )
        }
    }

    func test_validateExpiry_shouldReturnInvalid_whenYearIsInvalid() {
        let invalidYears = ["a", "ab", "13", "20", "2010", "2000"]
        invalidYears.forEach {
            XCTAssertEqual(
                RyftInputValidationState.invalid,
                RyftCardValidation.validate(expirationMonth: "10", expirationYear: $0)
            )
        }
    }

    func test_validateExpiry_shouldReturnIncomplete_whenYearIsValid_butMonthIsIncomplete() {
        let incompleteMonths = ["0", "1"]
        incompleteMonths.forEach {
            XCTAssertEqual(
                RyftInputValidationState.incomplete,
                RyftCardValidation.validate(expirationMonth: $0, expirationYear: "42")
            )
        }
    }

    func test_validateExpiry_shouldReturnIncomplete_whenMonthIsValid_butYearIsIncomplete() {
        let incompleteYears = ["2", "3"]
        incompleteYears.forEach {
            XCTAssertEqual(
                RyftInputValidationState.incomplete,
                RyftCardValidation.validate(expirationMonth: "08", expirationYear: $0)
            )
        }
    }

    func test_validateExpiry_shouldReturnValid_whenExpiryIsComplete() {
        let testCases = [
            ["01", "30"],
            ["02", "30"],
            ["03", "30"],
            ["04", "30"],
            ["05", "30"],
            ["06", "30"],
            ["07", "30"],
            ["08", "30"],
            ["09", "30"],
            ["10", "30"],
            ["11", "30"],
            ["12", "30"]
        ]
        testCases.forEach {
            XCTAssertEqual(
                RyftInputValidationState.valid,
                RyftCardValidation.validate(expirationMonth: $0[0], expirationYear: $0[1])
            )
        }
    }

    func test_validateCvc_shouldReturnInvalid_whenValueContainsNonNumericCharacters() {
        let testCases = ["a", "ab", "ab1", "a_1" ]
        testCases.forEach {
            XCTAssertEqual(
                RyftInputValidationState.invalid,
                RyftCardValidation.validate(cvc: $0, with: .mastercard)
            )
        }
    }

    func test_validateCvc_shouldReturnIncomplete_whenCardSchemeIsUnknown() {
        let testCases = ["01", "1", "100"]
        testCases.forEach {
            XCTAssertEqual(
                RyftInputValidationState.incomplete,
                RyftCardValidation.validate(cvc: $0, with: .unknown)
            )
        }
    }

    func test_validateCvc_shouldReturnIncomplete_whenCvcIsTooShortForVisa() {
        let testCases = ["01", "1", "10"]
        testCases.forEach {
            XCTAssertEqual(
                RyftInputValidationState.incomplete,
                RyftCardValidation.validate(cvc: $0, with: .visa)
            )
        }
    }

    func test_validateCvc_shouldReturnIncomplete_whenCvcIsTooShortForMastercard() {
        let testCases = ["01", "1", "10"]
        testCases.forEach {
            XCTAssertEqual(
                RyftInputValidationState.incomplete,
                RyftCardValidation.validate(cvc: $0, with: .mastercard)
            )
        }
    }

    func test_validateCvc_shouldReturnIncomplete_whenCvcIsTooShortForAmex() {
        let testCases = ["01", "1", "100"]
        testCases.forEach {
            XCTAssertEqual(
                RyftInputValidationState.incomplete,
                RyftCardValidation.validate(cvc: $0, with: .amex)
            )
        }
    }

    func test_validateCvc_shouldReturnInvalid_whenCvcIsTooLongForVisa() {
        let testCases = ["0111", "1111", "1000"]
        testCases.forEach {
            XCTAssertEqual(
                RyftInputValidationState.invalid,
                RyftCardValidation.validate(cvc: $0, with: .visa)
            )
        }
    }

    func test_validateCvc_shouldReturnInvalid_whenCvcIsTooLongForMastercard() {
        let testCases = ["0111", "1111", "1000"]
        testCases.forEach {
            XCTAssertEqual(
                RyftInputValidationState.invalid,
                RyftCardValidation.validate(cvc: $0, with: .mastercard)
            )
        }
    }

    func test_validateCvc_shouldReturnInvalid_whenCvcIsTooLongForAmex() {
        let testCases = ["01111", "11111", "10000"]
        testCases.forEach {
            XCTAssertEqual(
                RyftInputValidationState.invalid,
                RyftCardValidation.validate(cvc: $0, with: .amex)
            )
        }
    }

    func test_validateCvc_shouldReturnValid_whenCvcIsCorrectLengthForVisa() {
        let testCases = ["011", "111", "100"]
        testCases.forEach {
            XCTAssertEqual(
                RyftInputValidationState.valid,
                RyftCardValidation.validate(cvc: $0, with: .visa)
            )
        }
    }

    func test_validateCvc_shouldReturnValid_whenCvcIsCorrectLengthForMastercard() {
        let testCases = ["011", "111", "100"]
        testCases.forEach {
            XCTAssertEqual(
                RyftInputValidationState.valid,
                RyftCardValidation.validate(cvc: $0, with: .mastercard)
            )
        }
    }

    func test_validateCvc_shouldReturnValid_whenCvcIsCorrectLengthForAmex() {
        let testCases = ["0111", "1111", "1000"]
        testCases.forEach {
            XCTAssertEqual(
                RyftInputValidationState.valid,
                RyftCardValidation.validate(cvc: $0, with: .amex)
            )
        }
    }

    func test_validateCardholderName_shouldReturnIncomplete_WhenNotEnoughWordsPresent() {
        let testCases = ["", " ", "one", "one "]
        testCases.forEach {
            XCTAssertEqual(
                RyftInputValidationState.incomplete,
                RyftCardValidation.validate(cardholderName: $0)
            )
        }
    }

    func test_validateCardholderName_shouldReturnIncomplete_WhenValueIsTooLong() {
        let testCases = [String(repeating: "A", count: 121)]
        testCases.forEach {
            XCTAssertEqual(
                RyftInputValidationState.invalid,
                RyftCardValidation.validate(cardholderName: $0)
            )
        }
    }

    func test_validateCardholderName_shouldReturnValid_WhenValueIsValid() {
        let maxLengthCase = "MR " + String(repeating: "A", count: 117)
        let testCases = [maxLengthCase, "MR A", "MR CAL KESTIS"]
        testCases.forEach {
            XCTAssertEqual(
                RyftInputValidationState.valid,
                RyftCardValidation.validate(cardholderName: $0)
            )
        }
    }
}
