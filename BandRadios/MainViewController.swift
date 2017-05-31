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

    var statusInfo: UILabel!

    lazy var streamURLPath: String = "http://evp.mm.uol.com.br:1935/bnewsfm_rj/bnewsfm_rj.sdp/playlist.m3u8"
    
    lazy var player: AVPlayer? = {
        guard let url = URL(string:self.streamURLPath ) else {
            print("impossible to load this url for streaming")
            return nil
        }
        return AVPlayer(url: url)
    }()
    
    var lastRadioId: Int = 3
    var currentRadioName = ""
    
    let bandLogo = UILabel(frame: CGRect.zero)
    var ledView = Controls.acessory.ledView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
        
        addAppLogo()
        addStatusInfo()
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadLastStationIfAny()
    }
    
    
    func loadLastStationIfAny() {
        
        let radioIdSaved = getSavedStation()
        if radioIdSaved < 1 {
            openStationsList()
        } else {
            if let name = UserDefaults.standard.string(forKey: "currentRadioName") {
                currentRadioName = name
                statusInfo.text = name
            }
            replaceStream(with: radioIdSaved)
            
        }
    }
    
    func addAppLogo() {
        
        bandLogo.translatesAutoresizingMaskIntoConstraints = false
        bandLogo.text = "BandNews"
        bandLogo.textAlignment = .center
        bandLogo.font = UIFont.systemFont(ofSize: 34, weight: UIFontWeightThin)
        bandLogo.textColor = .white
        bandLogo.sizeToFit()
        view.addSubview(bandLogo)
        bandLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bandLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -10).isActive = true
    }
    
    func addStatusInfo() {
        statusInfo = UILabel(frame: CGRect.zero)
        statusInfo.translatesAutoresizingMaskIntoConstraints = false
        statusInfo.textAlignment = .center
        statusInfo.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightThin)
        statusInfo.textColor = .highlightColor
        view.addSubview(statusInfo)
        statusInfo.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        statusInfo.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        statusInfo.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
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
        doubleTap.numberOfTapsRequired = 3
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
        stationsViewController.lastRadioId = lastRadioId
        stationsViewController.delegate = self

        let popoverPC = UIPopoverPresentationController(presentedViewController: stationsViewController, presenting: self)
        
        popoverPC.delegate = self as? UIPopoverPresentationControllerDelegate
        
        popoverPC.sourceView = self.view
        popoverPC.sourceRect = CGRect(x: 0, y: 0, width: 320, height: 480)
        
        present(stationsViewController, animated: true, completion: nil)
    }
    
    func replaceStream(with linkId: Int) {
        
        if lastRadioId == linkId { return }
        
        saveCurrentStation(linkId)
        
        let streamUrlPath = "http://webservice.bandradios.onebrasilmedia.com.br:8087/bandradios-api/retrieve-radio?1=1&rid=\(linkId)&auc=29E2A48D-BDD2-4589-9710-18A446A19B83"
        
        guard let streamUrl = URL(string: streamUrlPath) else { return }
        
        DataCache().getStreamInfo(for: streamUrl, id: linkId) { streamInfo in
            guard let streamInfo = streamInfo else { return }
            self.playStream(streamInfo)
        }
    }
    
    func saveCurrentStation(_ linkId: Int) {
        lastRadioId = linkId
        UserDefaults.standard.set(linkId, forKey: "currentStation")
        if let name = statusInfo.text {
            UserDefaults.standard.set(name, forKey: "currentRadioName")
        }
    }
    
    func getSavedStation() -> Int {
        return UserDefaults.standard.integer(forKey: "currentStation")
    }
    
    func playStream(_ streamInfo: StreamInfo) {
        guard let streamUrl = URL(string: streamInfo.path) else { return }
        let newStreamItem = AVPlayerItem(url: streamUrl)
        player?.replaceCurrentItem(with: newStreamItem)
        updateStatus(streamInfo.name)
    }
    
    func updateStatus(_ radioName: String) {
        DispatchQueue.main.async {
            self.statusInfo.text = radioName
        }
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

