//
//  GoogleSinglePlaceSearchService.swift
//  Places
//
//  Created by Jabari Bell on 12/7/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import GoogleMaps
import RxSwift


class GoogleSinglePlaceSearchService: GooglePlaceSearchable {
    
    //MARK: Property
    typealias T = FormattedGooglePlace
    let placesClient: GMSPlacesClient
    
    
    //MARK: Method
    init() {
        placesClient = GMSPlacesClient()
    }
    
    func getPlace(placeID: String) -> Observable<GoogleSinglePlaceSearchService.T> {
        return create { observer in
            let API = self
            API.placesClient.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
                if let error = error {
                    observer.onError(error)
                }
                if let place = place {
                    let formattedPlace = FormattedGooglePlace(placeID: place.placeID, formattedAddress: place.formattedAddress)
                    observer.onNext(formattedPlace)
                    observer.onCompleted()
                }
//                observer.onError() didn't find/parse place error
            })
            return NopDisposable.instance
        }
    }
}
