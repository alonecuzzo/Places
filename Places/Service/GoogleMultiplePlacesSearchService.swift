//
//  GoogleMultiplePlacesSearchService.swift
//  Places
//
//  Created by Jabari Bell on 12/7/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import GoogleMaps
import RxSwift


class GoogleMultiplePlacesSearchService: GooglePlacesSearchable {
    
    //MARK: Property
    typealias T = AutoCompleteGooglePrediction
    let placesClient: GMSPlacesClient
    
    
    //MARK: Method
    init() {
        placesClient = GMSPlacesClient()
    }
    
    func getPredictions(query: String, location: CLLocation) -> Observable<[GoogleMultiplePlacesSearchService.T]> {
        return create { observer in
            let API = self
            let northEast = CLLocationCoordinate2DMake(location.coordinate.latitude + 1, location.coordinate.longitude + 1)
            let southWest = CLLocationCoordinate2DMake(location.coordinate.latitude - 1, location.coordinate.longitude - 1)
            let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
            let filter = GMSAutocompleteFilter()
            filter.type = GMSPlacesAutocompleteTypeFilter.NoFilter
            
            if query.characters.count > 0 {
                print("Searching for '\(query)'")
                API.placesClient.autocompleteQuery(query, bounds: bounds, filter: filter, callback: { (results, error) -> Void in
                    
                    if let error = error {
                        observer.on(.Error(error))
                        return
                    }
                    
                    print("Populating results for query '\(query)'")
                    let places = results!.filter { $0 is GMSAutocompletePrediction }.map { gmsPrediction -> AutoCompleteGooglePrediction in
                        let prediction = gmsPrediction as! GMSAutocompletePrediction
                        
                        return AutoCompleteGooglePrediction(placeID: prediction.placeID, attributedText: prediction.attributedFullText)
                    }
                    observer.on(Event.Next(places))
                })
            }
            
            return NopDisposable.instance
        }
    }
}
