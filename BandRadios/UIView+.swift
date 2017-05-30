//
//  UIView+.swift
//  BandNews Player
//
//  Created by Daniel Bonates on 29/05/17.
//  Copyright © 2017 Daniel Bonates. All rights reserved.
//

import UIKit

extension UIView {
    var animationDuration: TimeInterval {
        return 0.35
    }
    
    func enlight(_ highlight: Bool = true) {
        if highlight {
            UIView.animate(withDuration: animationDuration, animations: {
                self.backgroundColor = self.backgroundColor?.lighter()
            }, completion: nil)
            
        } else {
            UIView.animate(withDuration: animationDuration, animations: {
                self.backgroundColor = self.backgroundColor?.darker()
            }, completion: nil)
        }
    }
}
