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
public class GooglePlacesSearchService: GooglePlaceSearchable {
    
    //MARK: Property
    private let resultsDescription: AutoCompletePlaceNumberOfResultsDescription
    
    private lazy var googleMultiplePlacesInternalAPI: EventPlacesSearchableThunk<AutoCompleteGooglePrediction> = { [weak self] in
        let resultsDescription = (self?.resultsDescription)!
        return EventPlacesSearchableThunk(GoogleMultiplePlacesSearchService(resultsDescription: resultsDescription))
    }()
    
    private lazy var googleSinglePlaceInternalAPI: EventPlaceSearchableThunk<FormattedGooglePlace> = {
        return EventPlaceSearchableThunk(GoogleSinglePlaceSearchService())
    }()
    
    
    //MARK: Method
    init(resultsDescription: AutoCompletePlaceNumberOfResultsDescription) {
        self.resultsDescription = resultsDescription
    }
    
    public func getPlace(placeID: String) -> Observable<FormattedGooglePlace> {
        return googleSinglePlaceInternalAPI.getPlace(placeID)
    }
    
    func getPredictions(query: String, coordinate: PlaceCoordinate, authorizationStatus: Variable<PlacesLocationAuthorizationStatus>) -> Observable<[AutoCompleteGooglePrediction]> {
        return googleMultiplePlacesInternalAPI.getPredictions(query, coordinate: coordinate, authorizationStatus: authorizationStatus)
    }
}
