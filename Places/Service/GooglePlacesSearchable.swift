//
//  GooglePlacesSearchable.swift
//  Places
//
//  Created by Jabari Bell on 11/16/15.
//  Copyright © 2015 Paperless Post. All rights reserved.
//

import Foundation
import RxSwift
import GoogleMaps


/**
 * Abstract representation of a Place that has a placeID.
 */
public protocol IdentifiablePlace {
    var placeID: String { get }
}

/**
 *  Abstract representation of a IdentifiablePlace that has an attributedFullText property.
 */
public protocol AutoCompleteGooglePredictionProtocol: IdentifiablePlace {
    var attributedFullText: NSAttributedString { get }
}

/**
 *  Abstraction of an IdentifiablePlace that has a formattedAddress property.
 */
public protocol FormattedGooglePlaceProtocol: IdentifiablePlace {
    var formattedAddress: String { get }
}


/**
 *  Intermediary model object that is an internal representation of a GMSAutoCompletePlace.
 *  This aids value injection on GMSAutoCompletePlaces.
 */
public struct AutoCompleteGooglePrediction: AutoCompleteGooglePredictionProtocol {
    
    //MARK: Property
    public var placeID: String
    public var attributedFullText: NSAttributedString
    public var placeName: String?
    
    
    //MARK: Method
    public init(placeID: String, attributedText: NSAttributedString) {
        self.placeID = placeID
        self.attributedFullText = attributedText
    }
}

/**
 *  Intermediary model object that is an internal representation of a GMSPlace.
 *  This aids value injection on GMSPlaces.
 */
public struct FormattedGooglePlace: FormattedGooglePlaceProtocol {
    
    //MARK: Property
    public var placeID: String
    public var formattedAddress: String
    
    
    //MARK: Method
    public init(placeID: String, formattedAddress: String) {
        self.placeID = placeID
        self.formattedAddress = formattedAddress
    }
}

/**
 *  Google Maps specific protocol for retrieving an Observable array of Google Autocomplete Predictions.
 */
protocol GooglePlacesSearchable {
    
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
 *  Thunk that acts as intermediary for generic typed GooglePlacesSearchable.
 *  More info on thunking: https://en.wikipedia.org/wiki/Thunk
 *  and: http://milen.me/writings/swift-generic-protocols/
 */
public struct GooglePlacesSearchableThunk<T: AutoCompleteGooglePredictionProtocol>: GooglePlacesSearchable {
    
    // MARK: Property
    private let _getPredictions: (String, PlaceCoordinate, Variable<PlacesLocationAuthorizationStatus>) -> Observable<[T]>
    
    
    // MARK: Method
    init<P: GooglePlacesSearchable where P.T == T>(_ dep: P) {
        _getPredictions = dep.getPredictions
    }
    
    func getPredictions(query: String, coordinate: PlaceCoordinate, authorizationStatus: Variable<PlacesLocationAuthorizationStatus>) -> Observable<[T]> {
        return _getPredictions(query, coordinate, authorizationStatus)
    }
}

/**
 *  Google Maps specific protocol for retrieving an Observable of type T.
 */
public protocol GooglePlaceSearchable {
    
    typealias T
    
    /**
     Returns an Observable for an object T.  Used for single GMSPlace retrieval from the Google Maps API.
     
     - parameter placeID: ID of AutoCompletePlace that was selected.
     
     - returns: Observable of type T.
     */
    func getPlace(placeID: String) -> Observable<T>
}

/**
 *  Thunk that acts as intermediary for generic typed GooglePlaceSearchable.
 *  More info on thunking: https://en.wikipedia.org/wiki/Thunk
 *  and: http://milen.me/writings/swift-generic-protocols/
 */
public struct GooglePlaceSearchableThunk<T: FormattedGooglePlaceProtocol>: GooglePlaceSearchable {
    
    // MARK: Property
    private let _getPlace: (String) -> Observable<T>
    
    
    // MARK: Method
    init<P: GooglePlaceSearchable where P.T == T>(_ dep: P) {
        _getPlace = dep.getPlace
    }
    
    public func getPlace(placeID: String) -> Observable<T> {
        return _getPlace(placeID)
    }
}

/**
 *  Abstract representation of a type that is able to return both FormattedGooglePlace and AutoCompleteGooglePrediction Observables.
 */
protocol GooglePlacesSearchMediator {
    func getPlace(placeID: String) -> Observable<FormattedGooglePlace>
    func getPredictions(query: String, coordinate: PlaceCoordinate, authorizationStatus: Variable<PlacesLocationAuthorizationStatus>) -> Observable<[AutoCompleteGooglePrediction]>
}
