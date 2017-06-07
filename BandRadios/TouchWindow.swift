//
//  TouchWindow.swift
//  TouchWindow
//
//  Created by Daniel Bonates on 07/06/17.
//  Copyright © 2017 Daniel Bonates. All rights reserved.
//

import UIKit

class TouchWindow: UIWindow {
    
    let touchSize: CGFloat = 28

    override func sendEvent(_ event: UIEvent) {
        
        guard let touches = event.allTouches else { return }
        
        for touch in touches {
            switch touch.phase {
            case .began:
                touchBegan(touch)
            case .moved:
                touchMoved(touch)
            default:
                break
            }
        }
        
        super.sendEvent(event)
    }
    
    func touchBegan(_ touch: UITouch) {
        let v = BallView(frame: CGRect(x: 0, y: 0, width: touchSize, height: touchSize))
        addSubview(v)
        v.center = touch.location(in: self)
    }
    func touchMoved(_ touch: UITouch) {
        let v = BallView(frame: CGRect(x: 0, y: 0, width: touchSize, height: touchSize))
        addSubview(v)
        v.center = touch.location(in: self)
        setNeedsDisplay()
        layer.setNeedsDisplay()
    }

}
