public struct RyftCardType: Equatable, Hashable {

    public let scheme: CardScheme
    public let displayName: String
    public let cardLengths: [Int]
    public let cvcLength: Int
    public let cardNumberFormatGaps: [Int]
    public let binRanges: [CardBinRange]

    public static let visa = RyftCardType(
        scheme: .visa,
        displayName: "Visa",
        cardLengths: [13, 16],
        cvcLength: 3,
        cardNumberFormatGaps: [4, 8, 12],
        binRanges: [CardBinRange(min: 4, max: 4)]
    )

    public static let mastercard = RyftCardType(
        scheme: .mastercard,
        displayName: "Mastercard",
        cardLengths: [16],
        cvcLength: 3,
        cardNumberFormatGaps: [4, 8, 12],
        binRanges: [
            CardBinRange(min: 2221, max: 2720),
            CardBinRange(min: 51, max: 55)
        ]
    )

    public static let amex = RyftCardType(
        scheme: .amex,
        displayName: "American Express",
        cardLengths: [15],
        cvcLength: 4,
        cardNumberFormatGaps: [4, 10],
        binRanges: [
            CardBinRange(min: 34, max: 34),
            CardBinRange(min: 37, max: 37)
        ]
    )

    public static let unknown = RyftCardType(
        scheme: .unknown,
        displayName: "Unknown",
        cardLengths: [24],
        cvcLength: 4,
        cardNumberFormatGaps: [],
        binRanges: []
    )

    public static let cardTypes: [CardScheme: RyftCardType] = [
        .visa: visa,
        .mastercard: mastercard,
        .amex: amex,
        .unknown: unknown
    ]
}
