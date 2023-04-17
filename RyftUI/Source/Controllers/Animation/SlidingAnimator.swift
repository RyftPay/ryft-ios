import UIKit

final class SlidingAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    enum AnimationType {
        case presenting
        case dismissing
    }

    private static let defaultDuration: CGFloat = 0.4

    private var duration: CGFloat = defaultDuration
    private var animationType = AnimationType.presenting
    private var onComplete: (() -> Void)?
    private var originFrame = CGRect.zero

    init(
        duration: CGFloat,
        animationType: AnimationType,
        onComplete: (() -> Void)? = nil
    ) {
        self.duration = duration
        self.animationType = animationType
        self.onComplete = onComplete
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(duration)
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch animationType {
        case .presenting:
            presentingAnimation(using: transitionContext)
        case .dismissing:
            dismissingAnimation(using: transitionContext)
        }
    }

    private func presentingAnimation(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
        containerView.addSubview(toViewController.view)
        let presentFrame = transitionContext.finalFrame(for: toViewController)
        let initialFrame = CGRect(
            origin: CGPoint(x: 0, y: UIScreen.main.bounds.size.height),
            size: presentFrame.size
        )
        toViewController.view.frame = initialFrame
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                toViewController.view.frame = presentFrame
            },
            completion: { _ in
                transitionContext.completeTransition(true)
            }
        )
    }

    private func dismissingAnimation(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from) else {
            return
        }
        let dismissFrame = CGRect(
            origin: CGPoint(x: 0, y: UIScreen.main.bounds.size.height),
            size: fromViewController.view.frame.size
        )
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                fromViewController.view.frame = dismissFrame
            },
            completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                self.onComplete?()
            }
        )
    }

    static func presentingAnimator() -> SlidingAnimator {
        SlidingAnimator(duration: defaultDuration, animationType: .presenting)
    }

    static func dismissAnimator(onComplete: (() -> Void)? = nil) -> SlidingAnimator {
        SlidingAnimator(
            duration: defaultDuration,
            animationType: .dismissing,
            onComplete: onComplete
        )
    }
}
