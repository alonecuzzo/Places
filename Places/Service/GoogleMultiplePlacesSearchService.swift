//
//  GoogleMultiplePlacesSearchService.swift
//  Places
//
//  Created by Jabari Bell on 12/7/15.
//  Copyright © 2015 Paperless Post. All rights reserved.
//

import Foundation
import GoogleMaps
import RxSwift


enum AutoCompletePlaceNumberOfResultsDescription: Int {
    case Default, Short
}

class GoogleMultiplePlacesSearchService: GooglePlacesSearchable {
    
    //MARK: Property
    typealias T = AutoCompleteGooglePrediction
    let placesClient: GMSPlacesClient
    let resultsDescription: AutoCompletePlaceNumberOfResultsDescription
    
    
    //MARK: Method
    init(resultsDescription: AutoCompletePlaceNumberOfResultsDescription) {
        self.resultsDescription = resultsDescription
        placesClient = GMSPlacesClient()
    }
    
    func getPredictions(query: String, coordinate: PlaceCoordinate, authorizationStatus: Variable<PlacesLocationAuthorizationStatus>) -> Observable<[GoogleMultiplePlacesSearchService.T]> {
        let description = resultsDescription
        
        switch authorizationStatus.value {
        case .Authorized:
            return Observable.create { observer in
                let API = self
                let northEast = CLLocationCoordinate2DMake(coordinate.latitude + 1, coordinate.longitude + 1)
                let southWest = CLLocationCoordinate2DMake(coordinate.latitude - 1, coordinate.longitude - 1)
                let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
                let filter = GMSAutocompleteFilter()
                filter.type = GMSPlacesAutocompleteTypeFilter.NoFilter
                
                if query.characters.count > 0 {
                    
                    API.placesClient.autocompleteQuery(query, bounds: bounds, filter: filter, callback: { (results, error) -> Void in
                        
                        if let error = error {
                            observer.on(.Error(error))
                            return
                        }
                        
                        guard let results = results else { return }
                        var tempResults: Array<AnyObject> = results
                        if description == .Short && results.count > 3 {
                            tempResults = Array(tempResults[0..<tempResults.count-2])
                        }
                        
                        let places = tempResults.filter { $0 is GMSAutocompletePrediction }.map { gmsPrediction -> AutoCompleteGooglePrediction in
                            let prediction = gmsPrediction as! GMSAutocompletePrediction
                            
                            return AutoCompleteGooglePrediction(placeID: prediction.placeID, attributedText: prediction.attributedFullText)
                        }
                        observer.on(Event.Next(places))
                    })
                }
                
                return NopDisposable.instance
            }
        default:
            return Observable.just([])
        }
    }
}
