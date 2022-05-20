import PassKit

public struct BillingAddress: Equatable, Hashable {

    public let firstName: String?
    public let lastName: String?
    public let lineOne: String?
    public let lineTwo: String?
    public let city: String?
    public let country: String
    public let postalCode: String
    public let region: String?

    public init(
        firstName: String?,
        lastName: String?,
        lineOne: String?,
        lineTwo: String?,
        city: String?,
        country: String,
        postalCode: String,
        region: String?
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.lineOne = lineOne
        self.lineTwo = lineTwo
        self.city = city
        self.country = country
        self.postalCode = postalCode
        self.region = region
    }

    public init?(pkContact: PKContact?) {
        guard let pkContact = pkContact, let postalAddress = pkContact.postalAddress else {
            return nil
        }
        self.firstName = pkContact.name?.givenName
        self.lastName = pkContact.name?.familyName
        self.lineOne = BillingAddress.stringValueIfNonBlank(postalAddress.street)
        self.lineTwo = nil
        self.city = BillingAddress.stringValueIfNonBlank(postalAddress.city)
        self.country = postalAddress.isoCountryCode
        self.postalCode = postalAddress.postalCode
        self.region = BillingAddress.stringValueIfNonBlank(postalAddress.state)
    }

    func toJson() -> [String: Any] {
        let json =
        [
            "firstName": firstName as Any?,
            "lastName": lastName as Any?,
            "lineOne": lineOne as Any?,
            "lineTwo": lineTwo as Any?,
            "city": city as Any?,
            "country": country,
            "postalCode": postalCode,
            "region": region as Any?
        ]
        return json.compactMapValues { $0 }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(firstName)
        hasher.combine(lastName)
        hasher.combine(lineOne)
        hasher.combine(lineTwo)
        hasher.combine(city)
        hasher.combine(country)
        hasher.combine(postalCode)
        hasher.combine(region)
    }

    public static func == (lhs: BillingAddress, rhs: BillingAddress) -> Bool {
        lhs.firstName == rhs.firstName
            && lhs.lastName == rhs.lastName
            && lhs.lineOne == rhs.lineOne
            && lhs.lineTwo == rhs.lineTwo
            && lhs.city == rhs.city
            && lhs.country == rhs.country
            && lhs.postalCode == rhs.postalCode
            && lhs.region == rhs.region
    }

    private static func stringValueIfNonBlank(_ value: String) -> String? {
        value.isEmpty ? nil : value
    }
}
