//
//  BallView.swift
//  TouchWindow
//
//  Created by Daniel Bonates on 07/06/17.
//  Copyright © 2017 Daniel Bonates. All rights reserved.
//

import UIKit

class BallView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: fadeAway)
    }
    
    func fadeAway() {
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.layer.opacity = 0
        }) { (finish) in
            
            self.removeFromSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.width / 2;
        layer.masksToBounds = true;
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
    }


}
