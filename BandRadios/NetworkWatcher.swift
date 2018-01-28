//
//  NetworkWatcher.swift
//  BandRadios
//
//  Created by Daniel Bonates on 22/08/17.
//  Copyright © 2017 Daniel Bonates. All rights reserved.
//

import UIKit

#if DEBUG
    
    private let swizzle: (String, String, URLSessionTask.Type) -> Void = { (originalMethod, swizzledMethod, task) in
            
        let originalSelector = Selector(originalMethod)
        let swizzledSelector = Selector(swizzledMethod)
        
        let originalMethod = class_getInstanceMethod(task, originalSelector)
        let swizzledMethod = class_getInstanceMethod(task, swizzledSelector)
        
        let didAddMethod = class_addMethod(task, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            class_replaceMethod(task, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    
    extension URLSessionTask {
        
        open override class func initialize() {
            
            
            if self !== URLSessionTask.self {
                return
            }
            
            let methods = ["resume": "watchedResume"]
            
            
            methods.forEach { (key, value) in
                swizzle(key, value, self)
            }
        }
        
        func watchedResume() {
            print("checar dados do request...")
            watchedResume()
        }
        
        
    }

#endif
