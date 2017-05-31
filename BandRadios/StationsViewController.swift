//
//  StationsViewController.swift
//  BandRadios
//
//  Created by Daniel Bonates on 30/05/17.
//  Copyright © 2017 Daniel Bonates. All rights reserved.
//

import UIKit

class StationsViewController: UITableViewController {
    
    // these are for help on scroll direction detection
    var toTop = false
    var currentOffset:CGFloat = 0
    let pullIntensity: CGFloat = 100
    
    var delegate: MainViewController?
    
    var lastRadioId: Int = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StationCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .defaultColor
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        tableView.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .allowUserInteraction, animations: { () -> Void in
            self.tableView.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)
    }
    
    var stations: [Station] = [] {
        didSet {
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StationCell", for: indexPath)

        cell.textLabel?.font = UIFont.systemFont(ofSize: 21, weight: UIFontWeightThin)
        cell.textLabel?.text = stations[indexPath.row].name

        cell.backgroundColor = .defaultColor
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.defaultColor.darker()
        cell.selectedBackgroundView = selectedView
        if stations[indexPath.row].id == lastRadioId {
            cell.accessoryView = Controls.acessory.ledView
            cell.textLabel?.textColor = .highlightColor
        } else {
            cell.accessoryView = nil
            cell.textLabel?.textColor = .white

        }
        return cell
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true, completion: nil)
        delegate?.replaceStream(with: stations[indexPath.row].id)
    }
    
    
    // works on animation
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        if !tableView.isDragging {
            // first animation, when not scrolling it should be simple
            return
        }
        
        cell.contentView.layer.opacity = 0
        
        
        if toTop {
            
            cell.contentView.transform = CGAffineTransform(translationX: 0, y: -pullIntensity)
            cell.textLabel?.transform = CGAffineTransform(translationX:0, y: -pullIntensity)
        } else {
            cell.contentView.transform = CGAffineTransform(translationX:0, y: pullIntensity)
            cell.textLabel?.transform = CGAffineTransform(translationX:0, y: pullIntensity)
        }
        
        
        
        // Do the animation
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            
            cell.contentView.transform = CGAffineTransform(translationX: 0, y: 0)
            cell.contentView.layer.opacity = 1
            
        }, completion: nil)
        
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            
            cell.textLabel?.transform = CGAffineTransform(translationX: 0, y: 0)
            
        }, completion: nil)
        
    }

    
    
    // updating tableView offset info
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        currentOffset = scrollView.contentOffset.y
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let newOffset = scrollView.contentOffset.y
        toTop = newOffset > currentOffset ? false : true
        currentOffset = newOffset
    }
}
