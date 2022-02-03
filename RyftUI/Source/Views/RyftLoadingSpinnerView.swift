import UIKit

final class RyftLoadingSpinnerView: UIView {

    private let circleLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        layer.addSublayer(circleLayer)
        circleLayer.strokeColor = UIColor.white.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = 2
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.frame.width / 2
        let path = UIBezierPath(ovalIn:
            CGRect(
                x: 0,
                y: 0,
                width: self.bounds.width,
                height: self.bounds.width
            )
        )
        circleLayer.path = path.cgPath
    }

    func startAnimating() {
        let startAnimation = StrokeAnimation(
            type: .start,
            beginTime: 0.25,
            fromValue: 0.0,
            toValue: 1.0,
            duration: 0.75
        )
        let endAnimation = StrokeAnimation(
            type: .end,
            fromValue: 0.0,
            toValue: 1.0,
            duration: 0.75
        )
        let rotationAnimation = CABasicAnimation()
        rotationAnimation.keyPath = "transform.rotation.z"
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = CFloat.pi * 2
        rotationAnimation.duration = 2
        rotationAnimation.repeatCount = .greatestFiniteMagnitude
        let strokeAnimationGroup = CAAnimationGroup()
        strokeAnimationGroup.duration = 1
        strokeAnimationGroup.repeatDuration = .infinity
        strokeAnimationGroup.animations = [startAnimation, endAnimation]
        circleLayer.add(strokeAnimationGroup, forKey: nil)
        layer.add(rotationAnimation, forKey: nil)
    }

    final class StrokeAnimation: CABasicAnimation {

        enum StrokeType {
            case start
            case end
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        init(
            type: StrokeType,
            beginTime: Double = 0.0,
            fromValue: CGFloat,
            toValue: CGFloat,
            duration: Double
        ) {
            super.init()

            self.keyPath = type == .start ? "strokeStart" : "strokeEnd"
            self.beginTime = beginTime
            self.fromValue = fromValue
            self.toValue = toValue
            self.duration = duration
            self.timingFunction = .init(name: .easeInEaseOut)
        }
    }
}
