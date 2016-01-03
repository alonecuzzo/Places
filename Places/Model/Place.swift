//
//  Place.swift
//  Places
//
//  Created by Jabari Bell on 11/17/15.
//  Copyright © 2015 Paperless Post. All rights reserved.
//

import Foundation
import RxSwift
import GoogleMaps


public struct Place {
    let placeName: String?
    let streetAddress: String?
    let cityTown: String?
    let state: String?
    let zipCode: String?
}

// MARK: - Debug
extension Place: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return "-----------------------------\n" +
                "Place Name: \(placeName!)\n" +
                "Street Address: \(streetAddress!)\n" +
                "City: \(cityTown!)\n" +
                "State: \(state!)\n" +
                "Zip Code: \(zipCode!)\n" +
                "-----------------------------\n"
    }
}

// MARK: - Internal/External Conversion
extension Place {
    func asInternalPlace() -> _Place {
        let place = _Place()
        if let placeName = placeName { place.name.value = placeName } else { place.name.value = "" }
        if let streetAddress = streetAddress { place.streetAddress.value = streetAddress } else { place.streetAddress.value = "" }
        if let cityTown = cityTown { place.cityTown.value = cityTown } else { place.cityTown.value = "" }
        if let state = state { place.state.value = state } else { place.state.value = "" }
        if let zipCode = zipCode { place.zipCode.value = zipCode } else { place.zipCode.value = "" }
        return place
    }
}

/**
 *  Internal model representation of a Place.
 */
public struct _Place {
    let placeID = Variable("")
    let name = Variable("")
    let streetAddress = Variable("")
    let cityTown = Variable("")
    let state = Variable("")
    let zipCode = Variable("")
    //coordinate? YES
    let location = Variable(CLLocation())//can be nil
    let detailString = Variable("") 
}

// MARK: - Conversion to externally consumed Place object
extension _Place {
    public func asExternalPlace() -> Place {
        return Place(placeName: name.value, streetAddress: streetAddress.value, cityTown: cityTown.value, state: state.value, zipCode: zipCode.value)
    }
}



// MARK: - Google Place conversion
extension _Place {
    public init(googlePlace: FormattedGooglePlace, withPlaceName placeName: String) {
        configureFormattedPlace(withString: googlePlace.formattedAddress) //this needs to be fixed
        placeID.value = googlePlace.placeID
        self.name.value = placeName
    }
}

extension _Place {
    public init(prediction: AutoCompleteGooglePrediction) {
        configurePrediction(withString: prediction.attributedFullText.string)
        placeID.value = prediction.placeID
    }
}

//TODO: needs sum serrrious testing
extension _Place {
    
    //configure single place
    func configureFormattedPlace(withString addressString: String) -> Void {
        
        func offsetIsValid(offset: Int, arrayLength: Int) -> Bool {
            let isValid = (arrayLength - offset) > 0
            return isValid
        }
        
        func valueForOffset(offset: Int, array: [String]) -> String {
            let value = offsetIsValid(offset, arrayLength: array.count) ? array[array.count - offset] : ""
            return value
        }
        
        let addressElements = addressString.componentsSeparatedByString(",")
        
        switch addressElements.count {
        
        case 1:
            return

        case 2:
            state.value = addressElements.first ?? ""
            
        default:
            let stateZip = valueForOffset(2, array: addressElements).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).componentsSeparatedByString(" ")
            state.value = stateZip.first ?? ""
            zipCode.value = stateZip.count > 1 ? stateZip[1] : ""
            
            cityTown.value = valueForOffset(3, array: addressElements).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            streetAddress.value = addressElements.count > 2 ? addressElements.first ?? "" : ""
        }

    }
    
    //configure prediction
    func configurePrediction(withString addressString: String) -> Void {
        
        let addressElements = addressString.componentsSeparatedByString(",")
        
        //remove the white space from the beginning of the detail string
        let detailStringWithSpace = addressElements[1..<addressElements.count].joinWithSeparator(", ")
        
        if detailStringWithSpace != "" {
            detailString.value = detailStringWithSpace.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        } else {
            detailString.value = ""
        }
        
        name.value = addressElements.first ?? ""
    }
}
