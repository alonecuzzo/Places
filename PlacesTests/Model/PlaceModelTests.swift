//
//  PlaceModelTests.swift
//  Places
//
//  Created by Sarah Griffis on 12/14/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import XCTest
import GoogleMaps

import Places

class PlaceModelTests: XCTestCase {
    
    
    override func setUp() {
        
        
        
    }
    
    
    func testThat() {
        let prediction = AutoCompleteGooglePrediction(placeID: "1234", attributedText: NSAttributedString(string: "123, Smith Ln, White Plains, NY 13422"))
        
        let placeToTest = _Place(prediction: prediction)
        print(placeToTest.asExternalPlace().debugDescription)
    }
    
}