//
//  Stream.swift
//  BandRadios
//
//  Created by Daniel Bonates on 30/05/17.
//  Copyright © 2017 Daniel Bonates. All rights reserved.
//

import Foundation

struct Stream {
    let id: Int
    let path: String
    let name: String
}

extension Stream {
    init?(from json: [String: Any]) {
        guard
            let id = json["id"] as? Int,
            let path = json["streamingURL"] as? String,
            let name = json["name"] as? String
        else { return nil }
        
        self.id = id
        self.path = path
        self.name = name
    }
}

extension Stream: Equatable {
    static func ==(lhs: Stream, rhs: Stream) -> Bool {
        return lhs.id == rhs.id && lhs.path == rhs.path && lhs.name == rhs.name
    }
}
