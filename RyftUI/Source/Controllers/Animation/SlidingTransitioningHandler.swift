import UIKit

final class SlidingTransitioningHandler: NSObject, UIViewControllerTransitioningDelegate {

    private let presenterTransition = SlidingAnimator(duration: 0.4, animationType: .presenting)
    private let dismissTransition = SlidingAnimator(duration: 0.4, animationType: .dismissing)
    private weak var presentedViewController: UIViewController?

    var height: CGFloat {
        didSet {
            guard let presentationController =
                    presentedViewController?.presentationController as? RyftDropInPresentationController else {
                return
            }
            presentationController.height = height
        }
    }

    var userInteractionEnabled: Bool {
        didSet {
            guard let presentationController =
                    presentedViewController?.presentationController as? RyftDropInPresentationController else {
                return
            }
            presentationController.dimmedViewInteractionEnabled = userInteractionEnabled
        }
    }

    init(presentedViewController: UIViewController, height: CGFloat) {
        self.height = height
        self.userInteractionEnabled = true
        self.presentedViewController = presentedViewController
    }

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        return RyftDropInPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            height: height
        )
    }

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return presenterTransition
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return dismissTransition
    }
}
