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

    var statusInfo: UIButton!

    var streamURLPath: String?
    
    let player = AVPlayer()
    
    var currentStream: Stream?
    
    let bandLogo = UILabel(frame: CGRect.zero)
    var ledView = Controls.acessory.ledView
    
    var bgView: UIImageView!
    
    var canSwipe = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBackGroundImageView()
        loadRandomBackground()
        setupGestures()
        
        addAppLogo()
        addStatusInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadLastStationIfAny()
    }
    
    func addBackGroundImageView() {
        
        bgView = UIImageView(frame: .zero)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.backgroundColor = .clear
        bgView.contentMode = .scaleAspectFill
        bgView.isOpaque = false
        bgView.alpha = 0.5
        view.addSubview(bgView)
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: view.topAnchor),
            bgView.leftAnchor.constraint(equalTo: view.leftAnchor),
            bgView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bgView.rightAnchor.constraint(equalTo: view.rightAnchor)
            ])
    }
    
    func loadRandomBackground() {
        
        if !canSwipe { return }
        
        canSwipe = false
        
        let url = URL(string: "https://api.unsplash.com/photos/random")!
        
        DataCache().getNiceBg(from: url) { image in
            guard let img = image else { return }
            DispatchQueue.main.async {
                self.swapBg(with: img)
            }
        }
    }
    
    func swapBg(with image: UIImage) {
        UIView.transition(with: self.bgView, duration: 1, options: [.allowUserInteraction, .transitionCrossDissolve], animations: {
            
            self.bgView.image = image
        }) { end in
            self.canSwipe = true
        }
    }
    
    func loadLastStationIfAny() {
        
        let radioIdSaved = getSavedStation()
        if radioIdSaved < 1 {
            openStationsList()
        } else {
            
            guard
                let name = UserDefaults.standard.string(forKey: "currentStream.name"),
                let path = UserDefaults.standard.string(forKey: "currentStream.path")
            else {
                openStationsList()
                return
            }
            
            let savedStream = Stream(id: radioIdSaved, path: path, name: name)
            setupStream(savedStream)
        }
    }
    
    func getSavedStation() -> Int {
        return UserDefaults.standard.integer(forKey: "currentStream.id")
    }
    
    func addAppLogo() {
        
        bandLogo.translatesAutoresizingMaskIntoConstraints = false
        bandLogo.text = "Nice Radio"
        bandLogo.textAlignment = .center
        bandLogo.font = UIFont.systemFont(ofSize: 34, weight: UIFontWeightThin)
        bandLogo.textColor = .white
        bandLogo.sizeToFit()
        view.addSubview(bandLogo)
        bandLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bandLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -10).isActive = true
    }
    
    func addStatusInfo() {
        statusInfo = UIButton(frame: CGRect.zero)
        statusInfo.translatesAutoresizingMaskIntoConstraints = false
        statusInfo.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightThin)
        statusInfo.setTitleColor( .highlightColor, for: .normal)
        view.addSubview(statusInfo)
        statusInfo.addTarget(self, action: #selector(statusInfotaped(_:)), for: .touchUpInside)
        statusInfo.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        statusInfo.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        statusInfo.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        statusInfo.backgroundColor = UIColor.black.withAlphaComponent(0.1)
    }
    
    func statusInfotaped(_ sender: Any){
        openStationsList()
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
        doubleTap.numberOfTouchesRequired = 1
        view.addGestureRecognizer(doubleTap)
        
        let swapLeft = UISwipeGestureRecognizer(target: self, action: #selector(loadRandomBackground))
        swapLeft.direction = .left
        view.addGestureRecognizer(swapLeft)
        
        let swapRight = UISwipeGestureRecognizer(target: self, action: #selector(loadRandomBackground))
        swapRight.direction = .right
        view.addGestureRecognizer(swapRight)
    }
    
    func openStationsList() {
        
        let url = URL(string: "http://webservice.bandradios.onebrasilmedia.com.br:8087/bandradios-api/retrieve-radio-list")!
        
        DataCache().getRadioList(from: url, completion: { stations in
            guard let stations = stations else { return }
            DispatchQueue.main.async {
                self.showStationsList(with: stations)
            }
        })
    }
    
    func showStationsList(with stations: [Station]) {
        
        let stationsViewController = StationsViewController(style: .plain)
        
        stationsViewController.modalPresentationStyle = .overCurrentContext
        stationsViewController.stations = stations
        if let currentStream = self.currentStream {
            stationsViewController.lastRadioId = currentStream.id
        }
        stationsViewController.delegate = self

        let popoverPC = UIPopoverPresentationController(presentedViewController: stationsViewController, presenting: self)
        
        popoverPC.delegate = self as? UIPopoverPresentationControllerDelegate
        
        popoverPC.sourceView = self.view
        popoverPC.sourceRect = CGRect(x: 0, y: 0, width: 320, height: 480)
        
        present(stationsViewController, animated: true, completion: nil)
    }
    
    func replaceStream(with station: Station) {
        guard
            currentStream?.id != station.id else { print("rádio já ativada."); return }
        
        let streamUrlPath = "http://webservice.bandradios.onebrasilmedia.com.br:8087/bandradios-api/retrieve-radio?1=1&rid=\(station.id)&auc=29E2A48D-BDD2-4589-9710-18A446A19B83"
        
        guard let streamUrl = URL(string: streamUrlPath) else { return }
        
        DataCache().getStreamInfo(for: streamUrl, id: station.id) { streamInfo in
            guard let streamInfo = streamInfo else { return }
            DispatchQueue.main.async {
                self.setupStream(streamInfo)
            }
        }
    }
    
    
    func setupStream(_ streamInfo: Stream) {
        
        self.currentStream = streamInfo
        guard let streamUrl = URL(string: streamInfo.path) else { return }
        let newStreamItem = AVPlayerItem(url: streamUrl)
        player.replaceCurrentItem(with: newStreamItem)
        updateStatus()
    }
    
    func updateStatus() {
        self.statusInfo.setTitle(currentStream?.name, for: .normal)
        saveCurrentStream()
    }
    
    func saveCurrentStream() {
        guard let currentStream = self.currentStream else {
            print("nenhuma radio ativa atualmente")
            return
        }
        
        UserDefaults.standard.set(currentStream.id, forKey: "currentStream.id")
        UserDefaults.standard.set(currentStream.name, forKey: "currentStream.name")
        UserDefaults.standard.set(currentStream.path, forKey: "currentStream.path")
    }
    
    
    func pause() {
        view.enlight(false)
        if player.timeControlStatus == .paused { return }
        player.pause()
        
    }
    func play() {
        
        guard player.currentItem != nil else {
            statusInfo.setTitle("Nenhuma rádio selecionada ainda", for: .normal)
            openStationsList()
            return
        }
        
        view.enlight()
        if player.timeControlStatus == .playing { return }
        player.play()
    }
}

