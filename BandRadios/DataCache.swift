//
//  DataCache.swift
//  BandRadios
//
//  Created by Daniel Bonates on 27/03/17.
//  Copyright © 2017 Daniel Bonates. All rights reserved.
//

import Foundation

final class DataCache {
    
    let cacheBasePath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    
    func cachePathFor(_ url: URL) -> URL {
        return cacheBasePath.appendingPathComponent(url.lastPathComponent)
    }
    
    func getResource(for url: URL, completion: @escaping ([Station]?) -> ()) {
        
        let localURL = cachePathFor(url)
        let localResource = stationsResource(for: localURL, isLocal: true)
        
        if FileManager.default.fileExists(atPath: localURL.path) {
            
            DataService().loadLocal(resource: localResource, completion: { stations in
                
                completion(stations)
            })
            
            
        } else {
            let sr = stationsResource(for: url, isLocal: false)
            DataService().load(resource: sr, completion: { stations in
                completion(stations)
            })
        }
        
        
        
       
        
    }
    
    func stationsResource(for url: URL, isLocal: Bool = true) -> Resource<[Station]> {
    
        let stationsResource = Resource<[Station]>(url: url, parse: { data in
            
            do {
                let localURL = self.cachePathFor(url)
                if !isLocal {
                    try data.write  (to: localURL)
                } else {
                    
                }
                let newData = try Data(contentsOf: localURL)
                
                if let json = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as? [String: Any] {
                    
                    return (self.stations(from: json))
                    
                }
            } catch let error {
                print(error.localizedDescription)
            }
            
            return nil
        })
        
        return stationsResource
    }
    
    
    func stations(from json: [String: Any]) -> [Station]? {
        guard
            let resultDataJson = json["resultData"] as? [String: Any],
            let dataJson = resultDataJson["data"] as? [[String: Any]]
        else { return nil }
        
        return dataJson.flatMap(Station.init)
    }
    
    // clear the cache
    func clearCache() {
        do {
            let filePaths = try FileManager.default.contentsOfDirectory(atPath: cacheBasePath.path)
            for filePath in filePaths {
                try FileManager.default.removeItem(atPath: cacheBasePath.path + filePath)
            }
        } catch let error as NSError {
            print("Could not clear temp folder: \(error.debugDescription)")
        }
    }
}

