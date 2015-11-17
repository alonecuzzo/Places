//
//  GooglePlacesSearchable.swift
//  Places
//
//  Created by Jabari Bell on 11/16/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import GoogleMaps

/**
 *  Google Maps specific protocol for retrieving an Observable array of Google Autocomplete Predictions.
 */
public protocol GooglePlacesSearchable {
    /**
     Retrieves predictions from Google Maps API.
     
     - parameter query:    String query to send up.
     - parameter location: Location to search around.
     
     - returns: An Observable array of Google Auto complete predictions.
     */
    func getPredictions(query: String, location: CLLocation) -> Observable<[GMSAutocompletePrediction]>
}
