//
//  PlaceModelTests.swift
//  Places
//
//  Created by Sarah Griffis on 12/14/15.
//  Copyright © 2015 Paperless Post. All rights reserved.
//

import Foundation
import XCTest
import GoogleMaps


@testable import Places

class PlaceModelTests: XCTestCase {
    
    
//    override func setUp() {
//        
//    }

    
    func testThatTheGooglePlaceWithOnlyAStateParsesCorrectly() {
    
        let googlePlace = FormattedGooglePlace(placeID: "1234", formattedAddress: "Pennsylvania, USA")
        let placeToTest = _Place(googlePlace: googlePlace, withPlaceName: "Pennsylvania")
        
        let debugString = "-----------------------------\n" +
            "Place Name: Pennsylvania\n" +
            "Street Address: \n" +
            "City: \n" +
            "State: Pennsylvania\n" +
            "Zip Code: \n" +
        "-----------------------------\n"
        
        XCTAssertTrue(placeToTest.asExternalPlace().debugDescription == debugString, "State only address should only have state.")
    }
    
    func testThatGooglePlaceWithFullAddressParsesCorrectly() {
    
        let googlePlace = FormattedGooglePlace(placeID: "1234", formattedAddress: "115 Broadway, New York, NY 10006, United States")
        let placeToTest = _Place(googlePlace: googlePlace, withPlaceName: "Paperless Post")
        
        let debugString = "-----------------------------\n" +
            "Place Name: Paperless Post\n" +
            "Street Address: 115 Broadway\n" +
            "City: New York\n" +
            "State: NY\n" +
            "Zip Code: 10006\n" +
        "-----------------------------\n"
        
        XCTAssertTrue(placeToTest.asExternalPlace().debugDescription == debugString, "Full address should parse into correct components.")
    }
    
    func testThatPlaceIdHasSameFormatFromGoogle() {
    
        let placeId = "ChIJid9ORBdawokR3b2AD1VBLD8"
        GMSServices.provideAPIKey("AIzaSyCQj8eAOjVBgdXO9MZEF9I6zzKjSJcssZg")
        let placesClient = GMSPlacesClient()

        placesClient.lookUpPlaceID(placeId) { (gmplace, error) -> Void in
            
            XCTAssertTrue(gmplace?.formattedAddress == "115 Broadway, New York, NY 10006, United States", "Google service should return a string in a certain format")
        }
    }


    //test paperless post place id (to test the SDK hasn't changed)
    //
    
    //test description and name parsing
    //Papermill Road, Reading, PA, United States
    //Paperless Post, Broadway, New York, NY, United States
    //Pennington, NJ, United States
    
    
}