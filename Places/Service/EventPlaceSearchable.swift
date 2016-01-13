//
//  EventPlaceSearchable.swift
//  EventDetails
//
//  Created by Sarah Griffis on 1/11/16.
//  Copyright © 2016 PaperlessPost. All rights reserved.
//

import Foundation
import RxSwift


/**
 *  Google Maps specific protocol for retrieving an Observable array of Google Autocomplete Predictions.
 */
protocol EventPlacesSearchable {
    
    typealias T
    
    /**
     Retrieves predictions from Google Maps API.
     
     - parameter query:    String query to send up.
     - parameter location: Location to search around.
     
     - returns: An Observable array of Google Auto complete predictions.
     */
    func getPredictions(query: String, coordinate: PlaceCoordinate, authorizationStatus: Variable<PlacesLocationAuthorizationStatus>) -> Observable<[T]>
}


/**
 *  Google Maps specific protocol for retrieving an Observable of type T.
 */
public protocol EventPlaceSearchable {
    
    typealias T
    
    /**
     Returns an Observable for an object T.  Used for single GMSPlace retrieval from the Google Maps API.
     
     - parameter placeID: ID of AutoCompletePlace that was selected.
     
     - returns: Observable of type T.
     */
    func getPlace(placeID: String) -> Observable<T>
}
