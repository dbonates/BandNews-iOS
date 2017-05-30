//
//  GSTouchImageViewQueue.swift
//  BandRadios
//
//  Created by Daniel Bonates on 30/05/17.
//  Copyright © 2017 Daniel Bonates. All rights reserved.
//

import UIKit

class GSTouchImageViewQueue {
    var backingArray: [UIImageView]!

    init(with touchCount: Int) {
     
        var arr = [UIImageView]()
        for _ in 0..<touchCount {
            if let img = UIImage(named: "touchImage") {
                arr.append(UIImageView(image: img))
            }
        }
        backingArray = arr
    }
    
    func popTouchImageView() -> UIImageView {
        guard let touchImageView = backingArray.first else { return UIImageView() }
        backingArray.remove(at: 0)
        return touchImageView
    }
    
    func pushTouchImageView(touchImageView: UIImageView) {
        backingArray.append(touchImageView)
    }
}
