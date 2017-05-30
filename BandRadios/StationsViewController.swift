//
//  StationsViewController.swift
//  BandRadios
//
//  Created by Daniel Bonates on 30/05/17.
//  Copyright © 2017 Daniel Bonates. All rights reserved.
//

import UIKit

class StationsViewController: UITableViewController {
    
    var delegate: MainViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StationCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .defaultColor
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
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

        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont.systemFont(ofSize: 24, weight: UIFontWeightThin)
        cell.textLabel?.text = stations[indexPath.row].name

        cell.backgroundColor = .defaultColor
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.defaultColor.darker()
        cell.selectedBackgroundView = selectedView
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true, completion: nil)
        delegate?.replaceStream(with: stations[indexPath.row].id)
    }
}
