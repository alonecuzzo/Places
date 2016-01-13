//
//  GooglePlacesSearchable.swift
//  Places
//
//  Created by Jabari Bell on 11/16/15.
//  Copyright © 2015 Paperless Post. All rights reserved.
//

import Foundation
import RxSwift

/**
 *  Abstract representation of a type that is able to return both FormattedGooglePlace and AutoCompleteGooglePrediction Observables.
 */
protocol GooglePlaceSearchable {
    func getPlace(placeID: String) -> Observable<FormattedGooglePlace>
    func getPredictions(query: String, coordinate: PlaceCoordinate, authorizationStatus: Variable<PlacesLocationAuthorizationStatus>) -> Observable<[AutoCompleteGooglePrediction]>
}
