//
//  Color+.swift
//  BandNews Player
//
//  Created by Daniel Bonates on 29/05/17.
//  Copyright © 2017 Daniel Bonates. All rights reserved.
//

import Foundation


enum ColorComponent {
    case brightness, hue
}

// iOS or macOS agnostic :D
#if os(OSX)
    
    import Cocoa
    public  typealias DBColor = NSColor
    
#else
    
    import UIKit
    public  typealias DBColor = UIColor
    
#endif

extension DBColor {
    
    func lighter(amount : CGFloat = 0.25) -> DBColor {
        return colorBy(changing: .brightness, with: 1 + amount)
    }
    
    func darker(amount : CGFloat = 0.25) -> DBColor {
        return colorBy(changing: .brightness, with: 1 - amount)
    }
    
    func colorUp(amount : CGFloat = 0.25) -> DBColor {
        return colorBy(changing: .hue, with: 1 + amount)
    }
    
    func colorDn(amount : CGFloat = 0.25) -> DBColor {
        return colorBy(changing: .hue, with: 1 - amount)
    }
    
    private func colorBy(changing component: ColorComponent = .brightness, with amount: CGFloat) -> DBColor {
        var hue         : CGFloat = 0
        var saturation  : CGFloat = 0
        var brightness  : CGFloat = 0
        var alpha       : CGFloat = 0
        
        #if os(iOS)
            
            if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
                switch component {
                case .brightness:
                    brightness *= amount
                case .hue:
                    hue *= amount
                }
                return DBColor( hue: hue,
                                saturation: saturation,
                                brightness: brightness,
                                alpha: alpha )
            } else {
                return self
            }
            
        #else
            
            getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            switch component {
            case .brightness:
                brightness *= amount
            case .hue:
                hue *= amount
            }
            return DBColor( hue: hue,
                            saturation: saturation,
                            brightness: brightness,
                            alpha: alpha )
            
        #endif
        
    }
    
}

extension DBColor {
    #if os(iOS)
        static var defaultColor: UIColor { return UIColor(colorLiteralRed: 26/255, green: 72/255, blue: 102/255, alpha: 1) }
        static var highlightColor: UIColor { return UIColor(colorLiteralRed: 51/255, green: 220/255, blue: 168/255, alpha: 1) }
    
    #else
        static var defaultColor: NSColor { return NSColor(colorLiteralRed: 26/255, green: 72/255, blue: 102/255, alpha: 1) }
        static var highlightColor: NSColor { return NSColor(colorLiteralRed: 51/255, green: 220/255, blue: 168/255, alpha: 1) }
    #endif
}
