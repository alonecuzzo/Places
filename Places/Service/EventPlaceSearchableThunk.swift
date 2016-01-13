//
//  EventPlaceSearchableThunk.swift
//  EventDetails
//
//  Created by Sarah Griffis on 1/11/16.
//  Copyright © 2016 PaperlessPost. All rights reserved.
//

import Foundation
import RxSwift


/**
 *  Thunk that acts as intermediary for generic typed GooglePlacesSearchable.
 *  More info on thunking: https://en.wikipedia.org/wiki/Thunk
 *  and: http://milen.me/writings/swift-generic-protocols/
 */
public struct EventPlacesSearchableThunk<T: AutoCompleteGooglePredictionProtocol>: EventPlacesSearchable {
    
    // MARK: Property
    private let _getPredictions: (String, PlaceCoordinate, Variable<PlacesLocationAuthorizationStatus>) -> Observable<[T]>
    
    
    // MARK: Method
    init<P: EventPlacesSearchable where P.T == T>(_ dep: P) {
        _getPredictions = dep.getPredictions
    }
    
    func getPredictions(query: String, coordinate: PlaceCoordinate, authorizationStatus: Variable<PlacesLocationAuthorizationStatus>) -> Observable<[T]> {
        return _getPredictions(query, coordinate, authorizationStatus)
    }
}


/**
 *  Thunk that acts as intermediary for generic typed GooglePlaceSearchable.
 *  More info on thunking: https://en.wikipedia.org/wiki/Thunk
 *  and: http://milen.me/writings/swift-generic-protocols/
 */
public struct EventPlaceSearchableThunk<T: FormattedGooglePlaceProtocol>: EventPlaceSearchable {
    
    // MARK: Property
    private let _getPlace: (String) -> Observable<T>
    
    
    // MARK: Method
    init<P: EventPlaceSearchable where P.T == T>(_ dep: P) {
        _getPlace = dep.getPlace
    }
    
    public func getPlace(placeID: String) -> Observable<T> {
        return _getPlace(placeID)
    }
}