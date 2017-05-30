//
//  Station.swift
//  BandRadios
//
//  Created by Daniel Bonates on 30/05/17.
//  Copyright © 2017 Daniel Bonates. All rights reserved.
//

import Foundation

struct Station {
    let id: Int
    let name: String
    let logoURL: URL
    let thumbnailURL: URL
    let cityName: String
    let stateName: String
}

extension Station {
    init?(json: [String: Any]) {
        guard
            let id = json["id"] as? Int,
            let name = json["name"] as? String,
            let logoURLPath = json["logoURL"] as? String,
            let logoURL = URL(string: logoURLPath),
            let thumbnailURLPath = json["thumbnailURL"] as? String,
            let thumbnailURL = URL(string: thumbnailURLPath),
            let cityJson = json["city"] as? [String: Any],
            let cityName = cityJson["name"] as? String,
            let regionJson = cityJson["region"] as? [String: Any],
            let stateName = regionJson["name"] as? String
        else { return nil }
        
        self.id = id
        self.name = name
        self.logoURL = logoURL
        self.thumbnailURL = thumbnailURL
        self.cityName = cityName
        self.stateName = stateName
    }
}
