import UIKit

final class RyftDropInPresentationController: UIPresentationController {

    private let maxDimmedAlpha: CGFloat = 0.6

    var height: CGFloat {
        didSet {
            UIView.animate(withDuration: 0.5) {
                self.containerViewWillLayoutSubviews()
            }
        }
    }

    var dimmedViewInteractionEnabled: Bool {
        didSet {
            dimmedView.isUserInteractionEnabled = dimmedViewInteractionEnabled
        }
    }

    private lazy var dimmedView: UIView = {
        let dimmedView = UIView(frame: CGRect(origin: .zero, size: UIScreen.main.bounds.size))
        dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0)
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        dimmedView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(onSwipe(_:)))
        swipeGesture.direction = [.down]
        dimmedView.addGestureRecognizer(tapGesture)
        dimmedView.addGestureRecognizer(swipeGesture)
        return dimmedView
    }()

    override var frameOfPresentedViewInContainerView: CGRect {
        CGRect(
            origin: CGPoint(x: 0, y: UIScreen.main.bounds.size.height - height),
            size: CGSize(width: presentedViewController.view.frame.size.width, height: height)
        )
    }

    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        height: CGFloat
    ) {
        self.height = height
        self.dimmedViewInteractionEnabled = true
        super.init(
            presentedViewController: presentedViewController,
            presenting: presentingViewController
        )
    }

    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    override func presentationTransitionWillBegin() {
        containerView?.insertSubview(dimmedView, at: 0)
        changeDimmedViewAlphaOnAnimation(to: maxDimmedAlpha)
    }

    override func dismissalTransitionWillBegin() {
        changeDimmedViewAlphaOnAnimation(to: 0)
    }

    @objc
    private func onTap(_ tap: UIGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }

    @objc
    private func onSwipe(_ tap: UIGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }

    private func changeDimmedViewAlphaOnAnimation(to alpha: CGFloat) {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmedView.backgroundColor = UIColor.black.withAlphaComponent(alpha)
            return
        }
        coordinator.animate(alongsideTransition: { _ in
            self.dimmedView.backgroundColor = UIColor.black.withAlphaComponent(alpha)
        })
    }
}
