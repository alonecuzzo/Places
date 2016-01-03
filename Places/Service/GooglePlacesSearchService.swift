//
//  GooglePlacesSearchService.swift
//  Places
//
//  Created by Jabari Bell on 11/16/15.
//  Copyright © 2015 Paperless Post. All rights reserved.
//

import Foundation
import RxSwift
import GoogleMaps


/**
 *  Concrete mediator that allows multiple and singular Place searches.
 */
public class GooglePlacesSearchService: GooglePlacesSearchMediator {
    
    //MARK: Property
    static let sharedAPI = GooglePlacesSearchService()
    
    private lazy var googleMultiplePlacesInternalAPI: GooglePlacesSearchableThunk<AutoCompleteGooglePrediction> = {
        return GooglePlacesSearchableThunk(GoogleMultiplePlacesSearchService())
    }()
    
    private lazy var googleSinglePlaceInternalAPI: GooglePlaceSearchableThunk<FormattedGooglePlace> = {
        return GooglePlaceSearchableThunk(GoogleSinglePlaceSearchService())
    }()
    
    
    //MARK: Method
    public init() {}
    
    public func getPlace(placeID: String) -> Observable<FormattedGooglePlace> {
        return googleSinglePlaceInternalAPI.getPlace(placeID)
    }
    
    public func getPredictions(query: String, coordinate: PlaceCoordinate) -> Observable<[AutoCompleteGooglePrediction]> {
        return googleMultiplePlacesInternalAPI.getPredictions(query, coordinate: coordinate)
    }
}
