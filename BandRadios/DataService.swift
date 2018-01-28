//
//  DataService.swift
//  GistIt
//
//  Created by Daniel Bonates on 27/03/17.
//  Copyright © 2017 Daniel Bonates. All rights reserved.
//

import Foundation

final class DataService {
    
    let cacheBasePath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    
    func cachePathFor(_ url: URL, id: Int? = nil) -> URL {
        if let id = id {
            return cacheBasePath.appendingPathComponent(url.lastPathComponent + "-\(id)")
        }
        return cacheBasePath.appendingPathComponent(url.lastPathComponent)
    }
    
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
            
            let localURL = self.cachePathFor(resource.url, id: resource.id)
            try? data.write(to: localURL)
        
            completion(resource.parse(data))
        })).resume()
    }
    
    func load<T>(resource: Resource<T>, headers: [String: String], parameters: [String: String], completion: @escaping (T?) -> ()) {
        
       
        guard var urlComponents = URLComponents(string: resource.url.absoluteString) else { return }
        
        urlComponents.queryItems = parameters.map {
            return URLQueryItem(name: $0.key, value: $0.value)
        }
        
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        
        for headerItem in headers {
            request.addValue(headerItem.value, forHTTPHeaderField: headerItem.key)
        }

        
        (URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil else { print(error.debugDescription); return }
            guard
                let response = response as? HTTPURLResponse,
                response.statusCode == 200
                else {
                    print("request failed for\(resource.url.absoluteString). Reason: no server response or statusCode != 200.")
                    return
            }
            guard let data = data else { completion(nil); return }
            
            let localURL = self.cachePathFor(resource.url, id: resource.id)
            try? data.write(to: localURL)
            
            completion(resource.parse(data))
        })).resume()
    }
    
    
    func loadLocal<T>(resource: Resource<T>, completion: @escaping (T?) -> ()) {
                
        let localURL = self.cachePathFor(resource.url, id: resource.id)
        
        guard let data = try? Data(contentsOf: localURL) else { completion(nil); return }
        
        completion(resource.parse(data))
    }
    
    
}


extension URLSession{
    open override class func initialize() {

        if self !== URLSession.self {
            return
        }
        
            let method1: Method = class_getInstanceMethod(self,#selector(URLSession.dataTask(with:completionHandler:) as (URLSession) -> (URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask));
            let method2 = class_getInstanceMethod(self, Selector(("my_dataTaskWithRequest:completionHandler:")));
            method_exchangeImplementations(method1, method2);
    }
    // Swizzled Method
    func my_dataTaskWithRequest(request: NSURLRequest,completionHandler: (NSData?, URLResponse?, Error?)) -> URLSessionDataTask {
        
        print("Inside Swizzled Method")
        
        return my_dataTaskWithRequest(request: request,completionHandler: completionHandler)
    }
}
