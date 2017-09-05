//
//  URLRequestTests.swift
//  DigidentityTest
//
//  Created by Adam Lovastyik [Standard] on 05/09/2017.
//  Copyright © 2017 Adam Lovastyik. All rights reserved.
//

import XCTest

class URLRequestTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    private let gmMethod = HTTPMethod.get
    private let gmBodyString = "TEST".data(using: .utf8)
    private let gmURL = BackendConfiguration.baseURL

    func testRequestConfoguration() {
        
        var request = URLRequest(url: gmURL)
        request.configure(for: gmMethod, with: gmBodyString)
        
        XCTAssertTrue(request.httpMethod == gmMethod.rawValue
            && request.url!.absoluteURL == gmURL
            && request.httpBody == gmBodyString
            , "URL request configuration OK")
    }
    
}
