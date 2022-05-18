import XCTest

final class RyftDropInPaymentViewControllerTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI Tests"]
        app.launch()
    }

    func test_dropIn_hasExpectedInputFields() throws {
        openDropIn()
        let cardInputField = app.otherElements["RyftCardNumberInputField"]
        let expirationInputField = app.otherElements["RyftExpirationInputField"]
        let cvcInputField = app.otherElements["RyftCvcInputField"]
        XCTAssertTrue(cardInputField.waitForExistence(timeout: 3))
        XCTAssertTrue(expirationInputField.exists)
        XCTAssertTrue(cvcInputField.exists)
        let cardNumberTextField = cardInputField.textFields.element
        let expirationTextField = expirationInputField.textFields.element
        let cvcTextField = cvcInputField.textFields.element
        XCTAssertEqual("Card Number", cardNumberTextField.placeholderValue)
        XCTAssertEqual("MM/YY", expirationTextField.placeholderValue)
        XCTAssertEqual("CVC", cvcTextField.placeholderValue)
    }

    func test_payButton_isDisabledOnLoad() throws {
        openDropIn()
        let payButton = app.otherElements["RyftConfirmButton-Pay"]
        XCTAssertTrue(payButton.waitForExistence(timeout: 3))
        XCTAssertFalse(payButton.buttons.element.isEnabled)
    }

    func test_cardNumber_isFormattedCorrect_duringTyping() throws {
        openDropIn()
        let cardNumberInput = app.otherElements["RyftCardNumberInputField"]
        XCTAssertTrue(cardNumberInput.waitForExistence(timeout: 3))

        cardNumberInput.textFields.element.tap()
        cardNumberInput.textFields.element.typeText("4242424242424242")
        XCTAssertEqual(
            "4242 4242 4242 4242",
            cardNumberInput.textFields.element.value as! String
        )
    }

    func test_expiration_isFormattedCorrectly_duringTyping() throws {
        openDropIn()
        let expirationInput = app.otherElements["RyftExpirationInputField"]
        XCTAssertTrue(expirationInput.waitForExistence(timeout: 3))

        expirationInput.textFields.element.tap()
        expirationInput.textFields.element.typeText("1022")
        XCTAssertEqual(
            "10/22",
            expirationInput.textFields.element.value as! String
        )
    }

    func test_focusIsAutoSwitchedToNextInput_whenPreviousBecomesValid() throws {
        openDropIn()
        let cardNumberInput = app.otherElements["RyftCardNumberInputField"]
        let expirationInput = app.otherElements["RyftExpirationInputField"]
        let cvcInput = app.otherElements["RyftCvcInputField"]
        XCTAssertTrue(cardNumberInput.waitForExistence(timeout: 3))

        cardNumberInput.textFields.element.tap()
        cardNumberInput.textFields.element.typeText("4242424242424242")
        expirationInput.textFields.element.typeText("1022")
        cvcInput.textFields.element.typeText("100")

        XCTAssertEqual(
            "4242 4242 4242 4242",
            cardNumberInput.textFields.element.value as! String
        )
        XCTAssertEqual(
            "10/22",
            expirationInput.textFields.element.value as! String
        )
        XCTAssertEqual(
            "100",
            cvcInput.textFields.element.value as! String
        )
    }

    func test_payButton_isEnabled_onceAllInputsAreValid() {
        openDropIn()
        typeCardDetails(
            cardNumber: "4242424242424242",
            expiration: "1022",
            cvc: "100"
        )
        let payButton = app.otherElements["RyftConfirmButton-Pay"]
        XCTAssertTrue(payButton.buttons.element.isEnabled)
    }

    func test_dropIn_isDismissed_afterClickingPay() {
        openDropIn()
        typeCardDetails(
            cardNumber: "4242424242424242",
            expiration: "1022",
            cvc: "100"
        )
        let payButton = app.otherElements["RyftConfirmButton-Pay"]
        payButton.buttons.element.tap()
        XCTAssertTrue(app.alerts.element.waitForExistence(timeout: 5))
    }

    func test_dropIn_isDismissed_afterClickingCancel() {
        openDropIn()
        let cancelButton = app.buttons["RyftButton-Cancel"]
        cancelButton.tap()
        XCTAssertFalse(app.buttons["RyftButton-Cancel"].exists)
    }

    private func openDropIn() {
        app.buttons["ShowDropInButton"].tap()
    }

    private func typeCardDetails(
        cardNumber: String,
        expiration: String,
        cvc: String
    ) {
        let cardNumberInput = app.otherElements["RyftCardNumberInputField"]
        let expirationInput = app.otherElements["RyftExpirationInputField"]
        let cvcInput = app.otherElements["RyftCvcInputField"]
        XCTAssertTrue(cardNumberInput.waitForExistence(timeout: 3))

        cardNumberInput.textFields.element.tap()
        cardNumberInput.textFields.element.typeText(cardNumber)
        expirationInput.textFields.element.typeText(expiration)
        cvcInput.textFields.element.typeText(cvc)
    }
}
