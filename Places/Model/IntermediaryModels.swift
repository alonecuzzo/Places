//
//  IntermediaryModels.swift
//  EventDetails
//
//  Created by Sarah Griffis on 1/11/16.
//  Copyright © 2016 PaperlessPost. All rights reserved.
//

import Foundation


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
