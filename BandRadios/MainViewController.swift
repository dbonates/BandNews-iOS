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


    lazy var streamURLPath: String = "http://evp.mm.uol.com.br:1935/bnewsfm_rj/bnewsfm_rj.sdp/playlist.m3u8"
    
    lazy var player: AVPlayer? = {
        guard let url = URL(string:self.streamURLPath ) else {
            print("impossible to load this url for streaming")
            return nil
        }
        return AVPlayer(url: url)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
        addAppLogo()
        
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadLastStationIfAny()
    }
    
    
    func loadLastStationIfAny() {
        DispatchQueue.main.async {
        
            let lastSavedId = self.getSavedStation()
            if lastSavedId < 1 {
                self.openStationsList()
            } else {
                self.replaceStream(with: lastSavedId)
                
            }
            
        }
        
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
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(openStationsList))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 2
        view.addGestureRecognizer(doubleTap)
    }
    
    func openStationsList() {
        
        let url = URL(string: "http://webservice.bandradios.onebrasilmedia.com.br:8087/bandradios-api/retrieve-radio-list")!
        
        DataCache().getResource(for: url, completion: { stations in
            guard let stations = stations else { return }
            self.showStationsList(with: stations)
        })
    }
    
    func showStationsList(with stations: [Station]) {
        
        let stationsViewController = StationsViewController(style: .plain)
        
        stationsViewController.modalPresentationStyle = .overCurrentContext
        stationsViewController.stations = stations
        stationsViewController.delegate = self
        
        let popoverPC = UIPopoverPresentationController(presentedViewController: stationsViewController, presenting: self)
        
        popoverPC.delegate = self as? UIPopoverPresentationControllerDelegate
        
        popoverPC.sourceView = self.view
        popoverPC.sourceRect = CGRect(x: 0, y: 0, width: 320, height: 480)
        
        present(stationsViewController, animated: true, completion: nil)
    }
    
    func replaceStream(with linkId: Int) {
        
        saveCurrentStation(linkId)
        
        let streamUrlPath = "http://webservice.bandradios.onebrasilmedia.com.br:8087/bandradios-api/retrieve-radio?1=1&rid=\(linkId)&auc=29E2A48D-BDD2-4589-9710-18A446A19B83"
        
        guard let streamUrl = URL(string: streamUrlPath) else { return }
        
        DataCache().getStreamInfo(for: streamUrl, id: linkId) { streamInfo in
            guard let streamInfo = streamInfo else { return }
            self.playStream(streamInfo.path)
        }
    }
    
    func saveCurrentStation(_ linkId: Int) {
        UserDefaults.standard.set(linkId, forKey: "currentStation")
    }
    
    func getSavedStation() -> Int {
        return UserDefaults.standard.integer(forKey: "currentStation")
    }
    
    func playStream(_ streamPath: String) {
        guard let streamUrl = URL(string: streamPath) else { return }
        let newStreamItem = AVPlayerItem(url: streamUrl)
        player?.replaceCurrentItem(with: newStreamItem)
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
    
    func loadData() {
        let url = URL(string: "http://webservice.bandradios.onebrasilmedia.com.br:8087/bandradios-api/retrieve-radio-list")!
        
        DataCache().getResource(for: url, completion: { stations in
            guard let stations = stations else { return }
            print("total de estações: \(stations.count)")
        })
    }
}

