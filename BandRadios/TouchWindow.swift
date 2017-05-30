//
//  TouchWindow.swift
//  BandRadios
//
//  Created by Daniel Bonates on 30/05/17.
//  Copyright © 2017 Daniel Bonates. All rights reserved.
//

import UIKit

class TouchWindow: UIWindow {

    lazy var touchImgViewQueue = GSTouchImageViewQueue(with: 8)
    var touchImgViewsDict = [String: UIImageView]()
    
    let animDuration: TimeInterval = 0.3
    let scaleAmount: CGFloat = 0.7
    let dumpingAmount: CGFloat = 0.7
    let scaleDownTouch: Bool = false
    
    override func sendEvent(_ event: UIEvent) {
        
        guard let touches = event.allTouches else { return }
        
        for touch in touches {
            switch touch.phase {
            case .began:
                touchBegan(touch)
            case .moved:
                touchMoved(touch)
            case .ended:
                touchEnded(touch)
            default:
                break
            }
        }
        
        super.sendEvent(event)
    }

    func touchBegan(_ touch: UITouch) {
        
        let touchImgView = touchImgViewQueue.popTouchImageView()
        
        touchImgView.center = touch.location(in: self)
        addSubview(touchImgView)
        
        touchImgView.alpha = 0
        
        if scaleDownTouch {
            touchImgView.transform = CGAffineTransform(scaleX: scaleAmount, y: scaleAmount)
        } else {
            touchImgView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        setTouchImageView(touchImgView, for: touch)
        
         UIView.animate(withDuration: animDuration, delay: 0, usingSpringWithDamping: dumpingAmount, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            touchImgView.alpha = 1
            if self.scaleDownTouch {
                touchImgView.transform = CGAffineTransform(scaleX: 1, y: 1)
            } else {
                touchImgView.transform = CGAffineTransform(scaleX: self.scaleAmount, y: self.scaleAmount)
            }
        })
    }
    
    func touchMoved(_ touch: UITouch) {
        let touchImgView: UIImageView = touchImageView(for: touch)
        touchImgView.center = touch.location(in: self)
    }
    
    func touchEnded(_ touch: UITouch) {
        
        let touchImgView: UIImageView = touchImageView(for: touch)
        
        UIView.animate(withDuration: animDuration, delay: 0, usingSpringWithDamping: dumpingAmount, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            touchImgView.alpha = 0
            if self.scaleDownTouch {
                touchImgView.transform = CGAffineTransform(scaleX: self.scaleAmount, y: self.scaleAmount)
            } else {
                touchImgView.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            
        }) { finished in
            touchImgView.removeFromSuperview()
            touchImgView.alpha = 1.0
            self.touchImgViewQueue.pushTouchImageView(touchImageView: touchImgView)
            self.removeTouchImageView(for: touch)
        }
    }
    
    func setTouchImageView(_ imgView: UIImageView, for touch: UITouch) {
        let touchStringHash = "\(touch.hash)"
        touchImgViewsDict[touchStringHash] = imgView
    }
    
    func touchImageView(for touch: UITouch) -> UIImageView {
        let touchStringHash = "\(touch.hash)"
        guard let imgView = touchImgViewsDict[touchStringHash] else { return UIImageView() }
        return imgView
    }

    func removeTouchImageView(for touch: UITouch) {
        let touchStringHash = "\(touch.hash)"
        touchImgViewsDict.removeValue(forKey: touchStringHash)
    }
}
