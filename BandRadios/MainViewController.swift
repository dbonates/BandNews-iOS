//
//  MainViewController.swift
//  BandRadios
//
//  Created by Daniel Bonates on 29/05/17.
//  Copyright © 2017 Daniel Bonates. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit

class MainViewController: UIViewController {


    lazy var player: AVPlayer? = {
        guard let url = URL(string: "http://evp.mm.uol.com.br:1935/bnewsfm_rj/bnewsfm_rj.sdp/playlist.m3u8") else {
            print("impossible to load this url for streaming")
            return nil
        }
        return AVPlayer(url: url)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
        addAppLogo()
    }
    
    
    func addAppLogo() {
        let bandLogo = UILabel(frame: CGRect.zero)
        bandLogo.translatesAutoresizingMaskIntoConstraints = false
        bandLogo.text = "BandNews"
        bandLogo.textAlignment = .center
        bandLogo.font = UIFont.systemFont(ofSize: 34, weight: UIFontWeightThin)
        bandLogo.textColor = .white
        bandLogo.sizeToFit()
        view.addSubview(bandLogo)
        bandLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bandLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupGestures() {
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(play))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(pause))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
    }
    
    func pause() {
        view.enlight(false)
        if player?.timeControlStatus == .paused { return }
        player?.pause()
    }
    func play() {
        view.enlight()
        if player?.timeControlStatus == .playing { return }
        player?.play()
    }
}

