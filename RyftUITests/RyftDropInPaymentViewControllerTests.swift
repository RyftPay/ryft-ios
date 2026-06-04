import XCTest

final class RyftDropInPaymentViewControllerTests: XCTestCase {

    var app: XCUIApplication!

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
        XCTAssertTrue(cardInputField.waitForExistence(timeout: 10))
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
        XCTAssertTrue(cardholderNameInputField.waitForExistence(timeout: 10))
        XCTAssertTrue(cardInputField.waitForExistence(timeout: 10))
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
        XCTAssertTrue(payButton.waitForExistence(timeout: 10))
        XCTAssertFalse(payButton.buttons.element.isEnabled)
    }

    func test_cardNumber_isFormattedCorrect_duringTyping() throws {
        openDropIn()
        let cardNumberInput = app.otherElements["RyftCardNumberInputField"]
        XCTAssertTrue(cardNumberInput.waitForExistence(timeout: 10))

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
        XCTAssertTrue(expirationInput.waitForExistence(timeout: 10))

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
        XCTAssertTrue(cardNumberInput.waitForExistence(timeout: 10))

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
        XCTAssertTrue(app.alerts.element.staticTexts["Payment Cancelled"].waitForExistence(timeout: 10))
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
        XCTAssertTrue(app.alerts.element.staticTexts["Payment Failed"].waitForExistence(timeout: 10))
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
        XCTAssertTrue(app.alerts.element.staticTexts["Payment Success"].waitForExistence(timeout: 10))
    }

    func test_dropIn_shouldDisplayAlert_whenApplePayPaymentFails_dueToApiError() {
        app.switches["ApplePayToggle"].forceTap()
        app.segmentedControls["FailPaymentControl"].buttons.element(boundBy: 0).forceTap()
        openDropIn()
        _ = payWithApplePay()
        XCTAssertTrue(app.alerts.element.staticTexts["Payment Failed"].waitForExistence(timeout: 10))
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
        XCTAssertTrue(app.alerts.element.staticTexts["Payment Success"].waitForExistence(timeout: 10))
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
        XCTAssertTrue(app.alerts.element.staticTexts["3DS Challenge"].waitForExistence(timeout: 10))
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
        XCTAssertTrue(app.alerts.element.staticTexts["3DS Challenge"].waitForExistence(timeout: 10))
        app.alerts.buttons["Pass"].forceTap()
        XCTAssertTrue(app.alerts.element.staticTexts["Payment Success"].waitForExistence(timeout: 10))
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
        XCTAssertTrue(cardNumberInput.waitForExistence(timeout: 10))

        cardNumberInput.textFields.element.tap()
        cardNumberInput.textFields.element.typeText(cardNumber)
        expirationInput.textFields.element.typeText(expiration)
        cvcInput.textFields.element.typeText(cvc)
    }

    private func toggleSaveCard() {
        let saveCardToggle = app.otherElements["RyftSaveCardToggleView"]
        XCTAssertTrue(saveCardToggle.waitForExistence(timeout: 10))

        saveCardToggle.images.element.tap()
    }

    private func payWithApplePay(customerEmail: String? = nil) -> XCUIApplication {
        let applePayButton = app.buttons["RyftApplePayButton"]
        applePayButton.forceTap()

        let applePay = XCUIApplication(bundleIdentifier: "com.apple.PassbookUIService")
        XCTAssertTrue(applePay.wait(for: .runningForeground, timeout: 25))
        // The redesigned (iOS 18+) sheet's accessibility hierarchy can take a few seconds to
        // become queryable after the sheet animates in; wait for the confirm button explicitly.
        XCTAssertTrue(
            applePay.buttons["total"].waitForExistence(timeout: 20),
            "Apple Pay sheet did not present - \(applePay.debugDescription)"
        )

        if let email = customerEmail {
            enterEmailAddressForApplePay(applePay, email: email)
        }
        enterBillingAddressForApplePay(applePay)
        return tapPayWithApplePayButton(applePay)
    }

    private func tapPayWithApplePayButton(_ applePay: XCUIApplication) -> XCUIApplication {
        /*
         * iOS 18+ : the sheet's "Pay" button has identifier 'total' (label
         * "Pay <merchant>, <amount>"). Tapping it opens a "Payment Summary" confirmation
         * sheet whose "Pay with Passcode" button actually authorises the payment. On the
         * pre-iOS-18 sheet "Pay with Passcode" was shown directly, so the initial tap is
         * only performed when the 'total' button is present.
         */
        let payButton = applePay.buttons["total"]
        if payButton.waitForExistence(timeout: 5) {
            payButton.tap()
        }
        let confirmButton = applePay.buttons["Pay with Passcode"].firstMatch
        XCTAssertTrue(
            confirmButton.waitForExistence(timeout: 15),
            "Could not find 'Pay with Passcode' confirmation in Apple Pay sheet - \(applePay.debugDescription)"
        )
        confirmButton.tap()
        return applePay
    }

    private func enterEmailAddressForApplePay(
        _ applePay: XCUIApplication,
        email: String
    ) {
        let alreadyEnteredContactEmail = applePay.buttons.containing(
            NSPredicate(format: "label contains 'Contact, \(email)'")
        ).firstMatch
        if alreadyEnteredContactEmail.waitForExistence(timeout: 10) {
            return
        }
        let addEmailButton = applePay.buttons["Add Email Address"].firstMatch
        XCTAssertTrue(
            addEmailButton.waitForExistence(timeout: 10),
            "Could not find 'Add Email Address' button in Apple Pay sheet"
        )
        addEmailButton.forceTap()
        let enterEmailButton = applePay.collectionViews.buttons["Add Email Address"]
        XCTAssertTrue(
            enterEmailButton.waitForExistence(timeout: 10),
            "Could not find enter email button in Apple Pay sheet"
        )
        enterEmailButton.forceTap()
        applePay.textFields.containing(NSPredicate(format: "placeholderValue contains 'Email'"))
            .firstMatch
            .typeText(email)
        applePay.buttons.containing(NSPredicate(format: "label contains 'Done'"))
            .firstMatch
            .forceTap()
    }

    private func enterBillingAddressForApplePay(_ applePay: XCUIApplication) {
        /*
         * iOS 18+ Apple Pay sheet: a billing address is added via a three-level flow —
         * tap the card (identifier 'pass') to open its detail view, tap the
         * 'billing-address' entry to open the address form, fill it, then save and
         * dismiss back to the payment sheet. When a billing address is already set the
         * card no longer shows "Add Billing Address" and there is nothing to do.
         */
        let cardNeedsBilling = applePay.buttons.containing(
            NSPredicate(format: "label contains 'Add Billing Address'")
        ).firstMatch
        guard cardNeedsBilling.waitForExistence(timeout: 10) else {
            return
        }

        applePay.buttons["pass"].firstMatch.forceTap()

        let billingAddressButton = applePay.buttons["billing-address"].firstMatch
        guard billingAddressButton.waitForExistence(timeout: 10) else {
            dismissApplePayDetailView(applePay)
            return
        }
        billingAddressButton.forceTap()

        fillApplePayTextField(applePay, identifier: "given-name", text: "Nathan")
        fillApplePayTextField(applePay, identifier: "family-name", text: "Test")
        fillApplePayTextField(applePay, identifier: "street-primary", text: "c/o Google LLC")

        // Save the address form ('next' = Done), then close the card detail view.
        let saveAddress = applePay.buttons["next"].firstMatch
        if saveAddress.waitForExistence(timeout: 5) {
            saveAddress.forceTap()
        }
        dismissApplePayDetailView(applePay)
    }

    private func dismissApplePayDetailView(_ applePay: XCUIApplication) {
        // The card detail view's "Done" button lives in a navigation bar (identifier 'dismiss'),
        // distinct from the payment sheet's 'close' button which is not in a navigation bar.
        let detailDone = applePay.navigationBars.buttons["dismiss"].firstMatch
        if detailDone.waitForExistence(timeout: 5) {
            detailDone.forceTap()
        }
    }

    private func fillApplePayTextField(
        _ applePay: XCUIApplication,
        identifier: String,
        text: String
    ) {
        let field = applePay.textFields[identifier].firstMatch
        guard field.waitForExistence(timeout: 5) else {
            return
        }
        field.forceTap()
        field.typeText(text)
    }

    private func collectCardholderName() {
        app.switches["CollectCardholderNameToggle"].tap()
    }
}
