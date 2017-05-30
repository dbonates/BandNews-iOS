//
//  DataService.swift
//  GistIt
//
//  Created by Daniel Bonates on 27/03/17.
//  Copyright © 2017 Daniel Bonates. All rights reserved.
//

import Foundation

final class DataService {
    func load<T>(resource: Resource<T>, completion: @escaping (T?) -> ()) {
        (URLSession.shared.dataTask(with: resource.url, completionHandler: { data, response, error in
            guard error == nil else { print(error.debugDescription); return }
            guard
                let response = response as? HTTPURLResponse,
                response.statusCode == 200
                else {
                    print("request failed for\(resource.url.absoluteString). Reason: no server response or statusCode != 200.")
                    return
            }
            guard let data = data else { completion(nil); return }
            completion(resource.parse(data))
        })).resume()
    }
    
    
    func loadLocal<T>(resource: Resource<T>, completion: @escaping (T?) -> ()) {
        
        guard let data = try? Data(contentsOf: resource.url) else { completion(nil); return }
        
        completion(resource.parse(data))
    }
}
