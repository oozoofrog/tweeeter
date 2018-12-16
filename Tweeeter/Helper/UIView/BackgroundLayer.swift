//
//  BackgroundLayer.swift
//  Tweeeter
//
//  Created by eyebookpro on 16/12/2018.
//  Copyright © 2018 ngenii. All rights reserved.
//

import UIKit

final class BackgroundLayer: CAShapeLayer {

    var frameObservable: NSKeyValueObservation?

    func setup(with view: UIView) {
        let observation = view.observe(\UIView.frame) { (_, _) in
            self.frame = self.superlayer?.bounds ?? .zero
        }
        self.frameObservable = observation
    }

    deinit {
        frameObservable?.invalidate()
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSublayers() {
        super.layoutSublayers()

        path = UIBezierPath(roundedRect: bounds.insetBy(dx: lineWidth, dy: lineWidth),
                            cornerRadius: cornerRadius).cgPath
    }

}

extension UIView {

    struct Key {
        static var backgroundLayer: Key = Key()
    }

    var backgroundLayer: BackgroundLayer? {
        get {
            return objc_getAssociatedObject(self, &Key.backgroundLayer) as? BackgroundLayer
        }
        set {
            if let previousLayer = self.backgroundLayer {
                previousLayer.removeFromSuperlayer()
            }
            objc_setAssociatedObject(self, &Key.backgroundLayer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            guard let backgroundLayer = newValue else { return }
            layer.insertSublayer(backgroundLayer, at: 0)
            backgroundLayer.setup(with: self)
            backgroundLayer.frame = self.bounds
        }
    }

}
