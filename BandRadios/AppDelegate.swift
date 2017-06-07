//
//  AppDelegate.swift
//  BandRadios
//
//  Created by Daniel Bonates on 29/05/17.
//  Copyright © 2017 Daniel Bonates. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var audioSession = AVAudioSession.sharedInstance()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
        self.window = TouchWindow(frame: UIScreen.main.bounds)
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let viewController = sb.instantiateViewController(withIdentifier: "MainVC")
        self.window!.rootViewController = viewController
        self.window!.makeKeyAndVisible()
        #endif
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        return true
    }
}

