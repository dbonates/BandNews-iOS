//
//  Controls.swift
//  BandRadios
//
//  Created by Daniel Bonates on 30/05/17.
//  Copyright © 2017 Daniel Bonates. All rights reserved.
//

import UIKit
enum Controls {
    
    case acessory
    
    var ledView: UIView {
        
        let accessorySize: CGFloat = 10
        
        let indicatorView = UIView(frame: CGRect(x: 0, y: 0, width: accessorySize, height: accessorySize))
        
        indicatorView.backgroundColor = .highlightColor
        indicatorView.layer.cornerRadius = accessorySize / 2
        return indicatorView
    }
}

