//
//  StationInfo.swift
//  BandRadios
//
//  Created by Daniel Bonates on 30/05/17.
//  Copyright © 2017 Daniel Bonates. All rights reserved.
//

import Foundation

struct StreamInfo {
    let path: String
}

extension StreamInfo {
    init?(from json: [String: Any]) {
        guard
            let path = json["streamingURL"] as? String
        else { return nil }
        
        self.path = path
    }
}
