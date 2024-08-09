import XCTest

final class RyftDropInPaymentViewControllerTests: XCTestCase {

    var app: XCUIApplication!

    private let visaCardButtonPredicate = NSPredicate(
        format: "label contains 'Simulated Card - Visa, ‪•••• 1234‬'"
    )
    private let masterCardButtonPredicate = NSPredicate(
        format: "label contains 'Simulated Card - MasterCard, ‪•••• 1234‬'"
    )

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI Tests"]
        app.launch()
        sleep(2) // some elements don't seem to become hittable unless we wait after launch
    }

    func test_dropIn_hasExpectedElementsAtTop_whenApplePayIsSupported() {
        app.switches["ApplePayToggle"].tap()
        openDropIn()
        XCTAssertTrue(app.buttons["RyftApplePayButton"].exists)
        XCTAssertFalse(app.staticTexts["RyftTitleLabel"].exists)
        XCTAssertTrue(app.staticTexts["RyftSeparatorMiddleLabel"].exists)
    }

    func test_dropIn_hasExpectedElementsAtTop_whenApplePayIsNotSupported() {
        openDropIn()
        XCTAssertFalse(app.buttons["RyftApplePayButton"].exists)
        XCTAssertTrue(app.staticTexts["RyftTitleLabel"].exists)
        XCTAssertFalse(app.staticTexts["RyftSeparatorMiddleLabel"].exists)
    }

    func test_dropIn_shouldAllowToggleToSaveCard() {
        openDropIn()
        toggleSaveCard()
    }

    func test_dropIn_shouldNotShowSaveCardToggle_whenUsageIsSetupCard() {
        app.segmentedControls["DropInUsageControl"].buttons.element(boundBy: 1).forceTap()
        openDropIn()
        let saveCardToggle = app.otherElements["RyftSaveCardToggleView"]
        XCTAssertFalse(saveCardToggle.waitForExistence(timeout: 3))
    }

    func test_dropIn_shouldDisplayAlert_whenApplePayPresentationFails_dueToFailureToFetchPayment() {
        app.switches["ApplePayToggle"].forceTap()
        app.switches["GetPaymentSessionErrorToggle"].forceTap()
        openDropIn()
        let applePayButton = app.buttons["RyftApplePayButton"]
        applePayButton.tap()
        XCTAssertTrue(app.alerts.element.waitForExistence(timeout: 5))
        XCTAssertTrue(app.alerts.element.staticTexts["Oops!"].exists)
    }

    func test_dropIn_hasExpectedInputFields() throws {
        openDropIn()
        let cardholderNameInputField = app.otherElements["RyftCardholderNameInputField"]
        let cardInputField = app.otherElements["RyftCardNumberInputField"]
        let expirationInputField = app.otherElements["RyftExpirationInputField"]
        let cvcInputField = app.otherElements["RyftCvcInputField"]
        XCTAssertFalse(cardholderNameInputField.waitForExistence(timeout: 3))
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

    func test_dropIn_hasExpectedInputFields_whenAlsoCollectingCardholderName() throws {
        collectCardholderName()
        openDropIn()
        let cardholderNameInputField = app.otherElements["RyftCardholderNameInputField"]
        let cardInputField = app.otherElements["RyftCardNumberInputField"]
        let expirationInputField = app.otherElements["RyftExpirationInputField"]
        let cvcInputField = app.otherElements["RyftCvcInputField"]
        XCTAssertTrue(cardholderNameInputField.waitForExistence(timeout: 3))
        XCTAssertTrue(cardInputField.waitForExistence(timeout: 3))
        XCTAssertTrue(expirationInputField.exists)
        XCTAssertTrue(cvcInputField.exists)
        let cardholderNameTextField = cardholderNameInputField.textFields.element
        let cardNumberTextField = cardInputField.textFields.element
        let expirationTextField = expirationInputField.textFields.element
        let cvcTextField = cvcInputField.textFields.element
        XCTAssertEqual("Name on card", cardholderNameTextField.placeholderValue)
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
        expirationInput.textFields.element.typeText("1032")
        XCTAssertEqual(
            "10/32",
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
        expirationInput.textFields.element.typeText("1032")
        cvcInput.textFields.element.typeText("100")

        XCTAssertEqual(
            "4242 4242 4242 4242",
            cardNumberInput.textFields.element.value as! String
        )
        XCTAssertEqual(
            "10/32",
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
            expiration: "1032",
            cvc: "100"
        )
        let payButton = app.otherElements["RyftConfirmButton-Pay"]
        XCTAssertTrue(payButton.buttons.element.isEnabled)
    }

    func test_payButton_isDisabled_whenCollectingCardholderName_andNotYetValid() {
        collectCardholderName()
        openDropIn()
        typeCardDetails(
            cardNumber: "4242424242424242",
            expiration: "1032",
            cvc: "100"
        )
        let payButton = app.otherElements["RyftConfirmButton-Pay"]
        XCTAssertFalse(payButton.buttons.element.isEnabled)
    }

    func test_payButton_isDisabled_whenCollectingCardholderName_andAllInputsAreValid() {
        collectCardholderName()
        openDropIn()
        typeCardDetails(
            cardNumber: "4242424242424242",
            expiration: "1032",
            cvc: "100",
            name: "MR TEST"
        )
        let payButton = app.otherElements["RyftConfirmButton-Pay"]
        XCTAssertTrue(payButton.buttons.element.isEnabled)
    }

    func test_dropIn_isDismissed_afterClickingPay() {
        openDropIn()
        typeCardDetails(
            cardNumber: "4242424242424242",
            expiration: "1032",
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

    func test_dropIn_shouldReturnCancelledResult_whenClickingCancelOnDropIn() {
        openDropIn()
        let cancelButton = app.buttons["RyftButton-Cancel"]
        cancelButton.tap()
        XCTAssertTrue(app.alerts.element.staticTexts["Payment Cancelled"].waitForExistence(timeout: 5))
    }

    func test_dropIn_shouldDisplayAlert_whenCardPaymentFails() {
        app.segmentedControls["FailPaymentControl"].buttons.element(boundBy: 0).forceTap()
        openDropIn()
        typeCardDetails(
            cardNumber: "5169750000001111",
            expiration: "1032",
            cvc: "100"
        )
        let payButton = app.otherElements["RyftConfirmButton-Pay"]
        payButton.buttons.element.tap()
        XCTAssertTrue(app.alerts.element.staticTexts["Payment Failed"].waitForExistence(timeout: 5))
    }

    func test_dropIn_shouldDisplaySuccess_whenCardPaymentSucceeds() {
        openDropIn()
        typeCardDetails(
            cardNumber: "5169750000001111",
            expiration: "1032",
            cvc: "100"
        )
        let payButton = app.otherElements["RyftConfirmButton-Pay"]
        payButton.buttons.element.tap()
        XCTAssertTrue(app.alerts.element.staticTexts["Payment Success"].waitForExistence(timeout: 5))
    }

    func test_dropIn_shouldDisplayAlert_whenApplePayPaymentFails_dueToApiError() {
        app.switches["ApplePayToggle"].forceTap()
        app.segmentedControls["FailPaymentControl"].buttons.element(boundBy: 0).forceTap()
        openDropIn()
        _ = payWithApplePay()
        XCTAssertTrue(app.alerts.element.staticTexts["Payment Failed"].waitForExistence(timeout: 5))
    }

    func test_dropIn_shouldDisplayErrorOnApplePaySheet_whenApplePayPaymentFails_dueToBillingAddressError() {
        app.switches["ApplePayToggle"].forceTap()
        app.segmentedControls["FailPaymentControl"].buttons.element(boundBy: 1).forceTap()
        openDropIn()
        let applePay = payWithApplePay()
        XCTAssertTrue(applePay.staticTexts["Update Billing Address"].waitForExistence(timeout: 5))
    }

    func test_dropIn_shouldDisplayErrorOnApplePaySheet_whenApplePayPaymentFails_dueToCustomerEmailError() {
        app.switches["ApplePayToggle"].forceTap()
        app.segmentedControls["FailPaymentControl"].buttons.element(boundBy: 2).forceTap()
        openDropIn()
        let applePay = payWithApplePay(customerEmail: "invalid")
        XCTAssertTrue(applePay.staticTexts["Update Shipping Contact"].waitForExistence(timeout: 5))
    }

    func test_dropIn_shouldDisplaySuccessAlert_whenApplePayPaymentSucceeds() {
        app.switches["ApplePayToggle"].forceTap()
        openDropIn()
        _ = payWithApplePay()
        XCTAssertTrue(app.alerts.element.staticTexts["Payment Success"].waitForExistence(timeout: 5))
    }

    func test_dropIn_shouldDisplayThreeDs_whenCardPaymentMovesToRequiredActionIdentify() {
        app.switches["AttemptPayment3DSToggle"].forceTap()
        openDropIn()
        typeCardDetails(
            cardNumber: "5169750000001111",
            expiration: "1032",
            cvc: "257"
        )
        let payButton = app.otherElements["RyftConfirmButton-Pay"]
        payButton.buttons.element.tap()
        XCTAssertTrue(app.alerts.element.staticTexts["3DS Challenge"].waitForExistence(timeout: 3))
    }

    func test_dropIn_shouldDisplaySuccessAfterThreeds_whenIdentifyChallengeIsHandledSuccessfully() {
        app.switches["AttemptPayment3DSToggle"].forceTap()
        openDropIn()
        typeCardDetails(
            cardNumber: "5169750000001111",
            expiration: "1032",
            cvc: "257"
        )
        let payButton = app.otherElements["RyftConfirmButton-Pay"]
        payButton.buttons.element.tap()
        XCTAssertTrue(app.alerts.element.staticTexts["3DS Challenge"].waitForExistence(timeout: 3))
        app.alerts.buttons["Pass"].forceTap()
        XCTAssertTrue(app.alerts.element.staticTexts["Payment Success"].waitForExistence(timeout: 5))
    }

    private func openDropIn() {
        app.buttons["ShowDropInButton"].tap()
    }

    private func typeCardDetails(
        cardNumber: String,
        expiration: String,
        cvc: String,
        name: String? = nil
    ) {
        if let name = name {
            let cardholderNameInput = app.otherElements["RyftCardholderNameInputField"]
            cardholderNameInput.textFields.element.tap()
            cardholderNameInput.textFields.element.typeText(name)
        }
        let cardNumberInput = app.otherElements["RyftCardNumberInputField"]
        let expirationInput = app.otherElements["RyftExpirationInputField"]
        let cvcInput = app.otherElements["RyftCvcInputField"]
        XCTAssertTrue(cardNumberInput.waitForExistence(timeout: 3))

        cardNumberInput.textFields.element.tap()
        cardNumberInput.textFields.element.typeText(cardNumber)
        expirationInput.textFields.element.typeText(expiration)
        cvcInput.textFields.element.typeText(cvc)
    }

    private func toggleSaveCard() {
        let saveCardToggle = app.otherElements["RyftSaveCardToggleView"]
        XCTAssertTrue(saveCardToggle.waitForExistence(timeout: 3))

        saveCardToggle.images.element.tap()
    }

    private func payWithApplePay(customerEmail: String? = nil) -> XCUIApplication {
        let applePayButton = app.buttons["RyftApplePayButton"]
        applePayButton.forceTap()

        let applePay = XCUIApplication(bundleIdentifier: "com.apple.PassbookUIService")
        XCTAssertTrue(applePay.wait(for: .runningForeground, timeout: 25))

        if let email = customerEmail {
            /*
             * when testing on a local env once you enter an email address the contact value on the
             * Apple Pay sheet is already populated so there's no need to fill it
             */
            enterEmailAddressForApplePay(applePay, email: email)
        }

        /*
         * ApplePay sheet within the simulator defaults to "Pay with Touch Id"
         * we need to select the already selected card again to have the "Pay with passcode"
         * button to show (which we can then tap in these tests)
         */
        var cardButton = applePay.buttons.containing(visaCardButtonPredicate).element
        XCTAssertTrue(cardButton.waitForExistence(timeout: 10))
        cardButton.tap()

        // enter billingAddress if not already present (required)
        enterBillingAddressForApplePay(applePay)

        // select the card again within the ApplePay sheet card selection
        cardButton = applePay.buttons.containing(masterCardButtonPredicate).element
        XCTAssertTrue(cardButton.waitForExistence(timeout: 10))
        cardButton.forceTap()
        let payButton = applePay.buttons["Pay with Passcode"]
        XCTAssertTrue(payButton.waitForExistence(timeout: 10))
        payButton.tap()
        return applePay
    }

    private func enterEmailAddressForApplePay(
        _ applePay: XCUIApplication,
        email: String
    ) {
        let addEmailButton = applePay.buttons["Add Email Address"]
        _ = addEmailButton.waitForExistence(timeout: 15)
        if addEmailButton.exists {
            applePay.buttons["Add Email Address"].forceTap()
            applePay.tables.cells["Add Email Address"].forceTap()
            applePay.textFields.containing(NSPredicate(format: "placeholderValue contains 'Email'"))
                .element
                .typeText(email)
            applePay.buttons.containing(NSPredicate(format: "label contains 'Done'"))
                .element
                .forceTap()
        }
    }

    private func enterBillingAddressForApplePay(_ applePay: XCUIApplication) {
        let addBillingAddress = applePay.buttons.containing(
            NSPredicate(format: "label contains 'Add Billing Address'")
        ).element
        _ = addBillingAddress.waitForExistence(timeout: 15)
        if addBillingAddress.exists {
            applePay.tables.cells["Add Billing Address"].forceTap()
            let firstNameCell = applePay.tables.cells["First Name"]
            let streetCell = applePay.tables.cells["Street, Search Contact or Address"]
            firstNameCell.forceTap()
            firstNameCell.typeText("Nathan")
            streetCell.forceTap()
            streetCell.typeText("c/o Google LLC")
            applePay.buttons.containing(NSPredicate(format: "label contains 'Done'"))
                .element
                .forceTap()
        }
    }

    private func collectCardholderName() {
        app.switches["CollectCardholderNameToggle"].tap()
    }
}
