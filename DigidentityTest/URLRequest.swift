//
//  URLRequest.swift
//  DigidentityTest
//
//  Created by Adam Lovastyik [Standard] on 05/09/2017.
//  Copyright © 2017 Adam Lovastyik. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    
    case post   = "POST"
    case patch  = "PATCH"
    case get    = "GET"
    case delete = "DELETE"
}

extension URLRequest {
    
    mutating func configure(for method: HTTPMethod, with data: Data? = nil) {
        
        httpMethod = method.rawValue
        
        addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        addValue("application/json", forHTTPHeaderField: "Accept")
        
        addValue(BackendConfiguration.APIheaderkey, forHTTPHeaderField: BackendConfiguration.APIHeaderField)
        
        httpBody = data
    }
    
}
