//
//  Resource.swift
//  GistIt
//
//  Created by Daniel Bonates on 27/03/17.
//  Copyright © 2017 Daniel Bonates. All rights reserved.
//

import Foundation

struct Resource<T> {
    var url: URL
    var parse: (Data) -> T?
}
