//
//  DigidentityTestTests.swift
//  DigidentityTestTests
//
//  Created by Adam Lovastyik [Standard] on 05/09/2017.
//  Copyright © 2017 Adam Lovastyik. All rights reserved.
//

import XCTest
@testable import DigidentityTest

class DigidentityTestTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    private let gmPhotoJSONData: [String: Any] = [
        Photo.JSONkeys.id: "VALIDID",
        Photo.JSONkeys.confidence: 0.123,
        Photo.JSONkeys.img: "VALIDIMG",
        Photo.JSONkeys.text: "VALIDTEXT"
    ]
    
    func testJSONParsing() {
        
        let context = CoreDataManager.sharedInstance.createNewManagedObjectContext()
        
        let photo = Photo.newPhoto(in: context)
        
        photo.update(with: gmPhotoJSONData)
        
        XCTAssertTrue(photo.id == gmPhotoJSONData[Photo.JSONkeys.id] as? String
            && photo.confidence == gmPhotoJSONData[Photo.JSONkeys.confidence] as? Double
            && photo.img == gmPhotoJSONData[Photo.JSONkeys.img] as? String
            && photo.text == gmPhotoJSONData[Photo.JSONkeys.text] as? String
            , "Photo data parsing OK")
    }
    
}
