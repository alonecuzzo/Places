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
 *  Concrete mediator that allows multiple and singular Place searches.
 */
class GooglePlacesSearchService: GooglePlacesSearchMediator {
    
    //MARK: Property
    static let sharedAPI = GooglePlacesSearchService()
    
    private lazy var googleMultiplePlacesInternalAPI: GooglePlacesSearchableThunk<AutoCompleteGooglePrediction> = {
        return GooglePlacesSearchableThunk(GoogleMultiplePlacesSearchService())
    }()
    
    private lazy var googleSinglePlaceInternalAPI: GooglePlaceSearchableThunk<FormattedGooglePlace> = {
        return GooglePlaceSearchableThunk(GoogleSinglePlaceSearchService())
    }()
    
    
    //MARK: Method
    func getPlace(placeID: String) -> Observable<FormattedGooglePlace> {
        return googleSinglePlaceInternalAPI.getPlace(placeID)
    }
    
    func getPredictions(query: String, location: CLLocation) -> Observable<[AutoCompleteGooglePrediction]> {
        return googleMultiplePlacesInternalAPI.getPredictions(query, location: location)
    }
}
