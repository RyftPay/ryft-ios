import UIKit

final class SlidingTransitioningHandler: NSObject, UIViewControllerTransitioningDelegate {

    private var presenterTransition = SlidingAnimator.presentingAnimator()
    private var dismissTransition = SlidingAnimator.dismissAnimator()
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

    init(
        presentedViewController: UIViewController,
        height: CGFloat,
        dismissTransition: SlidingAnimator
    ) {
        self.height = height
        self.userInteractionEnabled = true
        self.presentedViewController = presentedViewController
        self.dismissTransition = dismissTransition
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
