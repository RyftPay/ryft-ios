import UIKit

public final class RyftUITheme {

    public static let defaultTheme = RyftUITheme()

    public var primaryBackgroundColor: UIColor {
        if #available(iOS 13, *) {
            return .systemBackground
        }
        return .white
    }

    public var unselectedInputBorderColor: UIColor = .unselectedInputBorderColor
    public var selectedInputBorderColor: UIColor = .selectedInputBorderColor
    public var invalidColor: UIColor = .invalidColor
    public var emptyInputBackgroundColor: UIColor = .emptyInputBackgroundColor
    public var nonEmptyInputBackgroundColor: UIColor = .nonEmptyInputBackgroundColor
    public var separatorLineColor: UIColor = .separatorLineColor
    public var separatorMiddleLabelColor: UIColor = .separatorMiddleLabelColor
    public var cancelButtonBackgroundColor: UIColor = .cancelButtonBackgroundColor
    public var cancelButtonBorderColor: UIColor = .cancelButtonBorderColor
    public var cancelButtonTitleColor: UIColor = .cancelButtonTitleColor
}
