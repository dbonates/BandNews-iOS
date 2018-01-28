//
//  DataCache.swift
//  BandRadios
//
//  Created by Daniel Bonates on 27/03/17.
//  Copyright © 2017 Daniel Bonates. All rights reserved.
//

import UIKit

struct ImageSource: Codable {
    var id: String
    let regularURL: URL?
    let fullURL: URL?
    let smallURL: URL?
    
    
    enum ImageCodingKeys: String, CodingKey {
        case id
        case urls
    }
    
    // esse enum interno é apenas para descer um nível
    enum URLsKeys: String, CodingKey {
        case regular
        case full
        case small
    }
    
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: ImageCodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        

        // deep one level
        let urlsSources = try container.nestedContainer(keyedBy: URLsKeys.self, forKey: .urls)

        let regularURL = try urlsSources.decode(String.self, forKey: .regular)
        self.regularURL = URL(string: regularURL)

        let fullURL = try urlsSources.decode(String.self, forKey: .full)
        self.fullURL = URL(string: fullURL)
        
        let smallURL = try urlsSources.decode(String.self, forKey: .small)
        self.smallURL = URL(string: smallURL)
        
    }
    
}

final class DataCache {
    
    let cacheBasePath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    
    func cachePathFor(_ url: URL, id: Int? = nil) -> URL {
        
        if let id = id {
            return cacheBasePath.appendingPathComponent(url.lastPathComponent + "-\(id)")
        }
        return cacheBasePath.appendingPathComponent(url.lastPathComponent)
    }
    
    func getNiceBg(from url: URL, completion: @escaping (UIImage?) -> ()) {
        
        let imageResource = Resource<UIImage>(id: nil, url: url, parse: { data in
         
            let decoder = JSONDecoder()
            
            do {
                
                let imgJson = try decoder.decode(ImageSource.self, from: data)
                
                guard let imgURL = imgJson.regularURL else { return nil }
                
                let imgData = try Data(contentsOf: imgURL)
                
                return UIImage(data: imgData)
                
                
            } catch let error {
                print(error.localizedDescription)
            }
            return nil
        })
    
        let headers = ["Accept-Version": "v1", "Authorization": "Client-ID 5f2bef1fb96294cc4c0405df7c61a7c1e6cfb82509dc182cdda7ac618c2da794"]
        
        let parameters = ["query":"nature, mountain, zen", "orientation":"portrait", "collections":"1610442"]
        
        DataService().load(resource: imageResource, headers: headers, parameters: parameters) { image in
            completion(image)
        }
    }
    
    func getRadioList(from url: URL, completion: @escaping ([Station]?) -> ()) {
        
        let localURL = cachePathFor(url)
        let shouldLoadLocal = FileManager.default.fileExists(atPath: localURL.path)
        
        let loadURL = shouldLoadLocal ? localURL : url
        
        let sr = stationsResource(from: loadURL, isLocal: shouldLoadLocal)
        
        if shouldLoadLocal {
            DataService().loadLocal(resource: sr, completion: { stations in
                completion(stations)
            })
        } else {
            DataService().load(resource: sr, completion: { stations in
                completion(stations)
            })
        }
        
    }
    
    func stationsResource(from url: URL, isLocal: Bool = true) -> Resource<[Station]> {
    
        let stationsResource = Resource<[Station]>(id: nil, url: url, parse: { data in
            
            do {
                
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                    
                    return (self.stations(from: json))
                    
                }
            } catch let error {
                print(error.localizedDescription)
            }
            
            return nil
        })
        
        return stationsResource
    }
    
    func getStreamInfo(for url: URL, id: Int, completion: @escaping (Stream?) -> ()) {
        
        let localURL = cachePathFor(url, id: id)
        
        let shouldLoadLocal = FileManager.default.fileExists(atPath: localURL.path)
                
        let sr = streamInfoResource(from: url, id: id)
        
        if shouldLoadLocal {
            DataService().loadLocal(resource: sr, completion: { stationInfo in
                completion(stationInfo)
            })
        } else {
            DataService().load(resource: sr, completion: { stationInfo in
                completion(stationInfo)
            })
        }
        
    }
    
    func streamInfoResource(from url: URL, id: Int) -> Resource<Stream> {
        
        let stationInfoResource = Resource<Stream>(id: id, url: url, parse: { data in
            
            do {
                
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                    
                    guard
                        let resultDataJson = json["resultData"] as? [String: Any]
                        else { return nil }
                    
                    return (Stream(from: resultDataJson))
                    
                }
            } catch let error {
                print(error.localizedDescription)
            }
            
            return nil
        })
        
        return stationInfoResource
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
            let stationsSourcePath = cacheBasePath.appendingPathComponent("retrieve-radio-list").path
            if FileManager.default.fileExists(atPath: stationsSourcePath) {
                try FileManager.default.removeItem(atPath: stationsSourcePath)
            }
            
        } catch let error as NSError {
            print("Could not clear temp folder: \(error.debugDescription)")
        }
    }
}

