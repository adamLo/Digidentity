//
//  NetworkManager.swift
//  DigidentityTest
//
//  Created by Adam Lovastyik [Standard] on 05/09/2017.
//  Copyright © 2017 Adam Lovastyik. All rights reserved.
//

import Foundation

typealias PaginatedFetchCompletionBlockType = ((_ fetchCount: Int, _ firstId: String?, _ lastId: String?, _ error: Error?) -> ())

struct BackendConfiguration {
    
    static let APIheaderkey     = "248d3d3a7d0a6b4e1e6e81f28a001b17"
    static let APIHeaderField   = "Authorization"
    
    static let baseURL          = URL(string: "https://marlove.net/mock/v1")!
    
    static let itemsPath        = "items"
    static let itemPath         = "item"
    
    static let paramSinceId     = "since_id"
    static let paramMaxId       = "max_id"
}

class NetworkManager: NSObject {
    
    private lazy var defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    
    func fetchItems(sinceId: String? = nil, maxId: String? = nil, completion: PaginatedFetchCompletionBlockType?) {
        
        var queryItems = [URLQueryItem]()
        
        if sinceId != nil && sinceId!.characters.count > 0 {
            
            queryItems.append(URLQueryItem(name: BackendConfiguration.paramSinceId, value: sinceId!))
        }
        
        if maxId != nil && maxId!.characters.count > 0 {
            
            queryItems.append(URLQueryItem(name: BackendConfiguration.paramMaxId, value: maxId!))
        }
        
        let baseURL = BackendConfiguration.baseURL.appendingPathComponent(BackendConfiguration.itemsPath)
        
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = queryItems
        
        let url = queryItems.count > 0 ? urlComponents.url! : baseURL
        
        var request = URLRequest(url: url)
        request.configure(for: .get)
        
        let dataTask = defaultSession.dataTask(with: request) { (data, response, networkError) in
            
            if networkError != nil {
                
                completion?(0, nil, nil, networkError)
            }
            else {
            
                if data == nil || data!.isEmpty {
                    
                    completion?(0, nil, nil, nil)
                }
                else {
                    
                    do {
                        
                        if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [[String: Any]] {
                        
                            let context = CoreDataManager.sharedInstance.createNewManagedObjectContext()
                            
                            Photo.process(items: json, context: context, completion: completion)
                        }
                        else {
                            
                            completion?(0, nil, nil, NSError(domain: "Digidentity", code: -666, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Error parsing request", comment: "Error message when unable to parse response")]))
                        }
                    }
                    catch let jsonError {
                        
                        completion?(0, nil, nil, jsonError)
                    }
                }
            }
        }
        
        dataTask.resume()
    }

}
