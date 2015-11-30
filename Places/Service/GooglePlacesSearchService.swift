//
//  GooglePlacesSearchService.swift
//  Places
//
//  Created by Jabari Bell on 11/16/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import RxSwift
import GoogleMaps

/**
 *  Concrete implementation of GooglePlacesSearchable
 */
class GooglePlacesSearchService: GooglePlacesSearchable, GooglePlaceSearchable {
    
    //MARK: Property
    static let sharedAPI = GooglePlacesSearchService()
    let placesClient: GMSPlacesClient
    
    
    //MARK: Method
    private init() {
        placesClient = GMSPlacesClient()
    }
    
    func getPlace(placeID: String) -> Observable<GMSPlace> {
        return create { observer in
            let API = self
            API.placesClient.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
                if let error = error {
                    observer.onError(error)
                }
                if let place = place {
                    observer.onNext(place)
                    observer.onCompleted()
                }
//                observer.onError() didn't find/parse place error
            })
            return NopDisposable.instance
        }
    }
    
    func getPredictions(query: String, location: CLLocation) -> Observable<[GMSAutocompletePrediction]> {
        return create { observer in
            let API = self
            let northEast = CLLocationCoordinate2DMake(location.coordinate.latitude + 1, location.coordinate.longitude + 1)
            let southWest = CLLocationCoordinate2DMake(location.coordinate.latitude - 1, location.coordinate.longitude - 1)
            let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
            let filter = GMSAutocompleteFilter()
            filter.type = GMSPlacesAutocompleteTypeFilter.Establishment
            if query.characters.count > 0 {
                print("Searching for '\(query)'")
                API.placesClient.autocompleteQuery(query, bounds: bounds, filter: filter, callback: { (results, error) -> Void in
                    
                    if let error = error {
                        observer.on(.Error(error))
                        return
                    }
                    
                    print("Populating results for query '\(query)'")
                    let places = results!.filter { $0 is GMSAutocompletePrediction }.map { $0 as! GMSAutocompletePrediction }
                    observer.on(Event.Next(places))
                })
            }
            
            return NopDisposable.instance
        }
    }
    
}
