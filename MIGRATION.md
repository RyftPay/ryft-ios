# Migration Guide

## v1.x → v2.x

v2.0.0 replaces the Checkout.com 3DS SDK with the Ravelin 3DS SDK. The 3DS flow is now
two-stage (identify → challenge) rather than one-stage, but this is handled internally — the
public API for handling required actions (`pendingAction` → `handleRequiredAction`) is
unchanged from v1.x.

---

### 1. Update Swift Package Manager dependency

The Checkout.com 3DS SDK is removed. The Ravelin 3DS SDK is pulled in automatically as a
transitive dependency — no explicit changes to your own `Package.swift` or Xcode project are
required beyond updating the `ryft-ios` package version to `2.0.0`.

---

### 2. `pendingAction` and `handleRequiredAction` are unchanged

`RyftPaymentResult.pendingAction` and `RyftDropInPaymentViewController.handleRequiredAction`
behave exactly as they did in v1.x — no changes are required to your existing
`onPaymentResult` implementation.

---

### 3. Update `RequiredActionIdentifyApp` field usage

`RequiredActionIdentifyApp` no longer contains Checkout.com session credentials. It now
carries Ravelin-specific fields:

```swift
// v1.x
public struct RequiredActionIdentifyApp {
    public let sessionId: String
    public let sessionSecret: String
    public let scheme: String
    public let paymentMethodId: String
}

// v2.x
public struct RequiredActionIdentifyApp {
    public let ravelinPublicKey: String
    public let protocolVersion: String
    public let scheme: String
    public let paymentMethodId: String
}
```

Remove any references to `sessionId` and `sessionSecret`. The `ravelinPublicKey` is passed
directly to the Ravelin SDK — you do not need to handle it explicitly if you are using
`RyftDropInPaymentViewController`.

---

### 4. Handle the new `Challenge` required action type

`PaymentSessionActionType` has a new `challenge` case. If you switch over this enum in
custom code, add the new case:

```swift
// v1.x
switch requiredAction.type {
case .identify: ...
case .unknown:  ...
}

// v2.x
switch requiredAction.type {
case .identify:   ...
case .challenge:  ... // new — handled automatically by the drop-in
case .unknown:    ...
}
```

`PaymentSessionRequiredAction` now carries an additional nullable field:

```swift
// v2.x
public struct PaymentSessionRequiredAction {
    public let type: PaymentSessionActionType
    public let identify: RequiredActionIdentifyApp?
    public let challenge: ChallengeAction?   // new
}
```

---

### 5. `RyftApiClient` gains a new `continuePayment` method

The two-stage 3DS flow requires a new endpoint. `continuePayment` has been added to the
`RyftApiClient` protocol:

```swift
func continuePayment(
    request: ContinuePaymentRequest,
    accountId: String?,
    completion: @escaping PaymentSessionResponse
)
```

If you only use `DefaultRyftApiClient`, no changes are required. If you have your own custom
conformance to `RyftApiClient`, you must implement this method or your code will not compile.

---

### 6. `RyftRequiredActionComponent.handle()` now requires a presenting view controller

If you use `RyftRequiredActionComponent` directly (for handling required actions outside of
the standard checkout flow, e.g. a MIT payment where the bank mandates 3DS), the `handle`
method now requires a `presentingViewController` so the Ravelin SDK can present the 3DS
challenge:

```swift
// v1.x
component.handle(action: requiredAction)

// v2.x
component.handle(action: requiredAction, presentingViewController: self)
```

Full usage:

```swift
let component = RyftRequiredActionComponent(
    config: RyftRequiredActionComponent.Configuration(
        clientSecret: clientSecret,
        accountId: accountId
    ),
    apiClient: DefaultRyftApiClient(publicApiKey: publicApiKey)
)
component.delegate = self
component.handle(action: requiredAction, presentingViewController: self)

// Delegate callbacks (unchanged from v1.x)
func onRequiredActionInProgress() {
    showLoadingIndicator()
}

func onRequiredActionHandled(result: Result<PaymentSession, Error>) {
    switch result {
    case .success(let session):
        // inspect session.status to determine next step
        break
    case .failure(let error):
        showError(error.localizedDescription)
    }
}
```

---

### Removed fields — delete any direct references

| Removed (v1.x) | Replaced by (v2.x) |
|---|---|
| `RequiredActionIdentifyApp.sessionId` | `RequiredActionIdentifyApp.ravelinPublicKey` |
| `RequiredActionIdentifyApp.sessionSecret` | `RequiredActionIdentifyApp.protocolVersion` |

---
