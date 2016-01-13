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


protocol EventPlaceConvertible {
    var eventPlace: EventPlace { get }
}


protocol _EventPlaceConvertible {
    var _eventPlace: _EventPlace { get }
}


public struct EventPlace: _EventPlaceConvertible {
    
    //MARK: Property
    public let placeName: String?
    public let streetAddress: String?
    public let cityTown: String?
    public let state: String?
    public let zipCode: String?
    public let coordinate: PlaceCoordinate?
    
    var _eventPlace: _EventPlace {
        let place = _EventPlace()
        place.name.value =|| placeName
        place.streetAddress.value =|| streetAddress
        place.cityTown.value =|| cityTown
        place.state.value =|| state
        place.zipCode.value =|| zipCode
        return place
    }
    
    
    //MARK: Method
    public init(placeName: String?, streetAddress: String?, cityTown: String?, state: String?, zipCode: String?, coordinate: PlaceCoordinate?) {
        self.placeName = placeName
        self.streetAddress = streetAddress
        self.cityTown = cityTown
        self.state = state
        self.zipCode = zipCode
        self.coordinate = coordinate
    }
}

// MARK: - Debug
extension EventPlace: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return "-----------------------------\n" +
                "Place Name: \(placeName!)\n" +
                "Street Address: \(streetAddress!)\n" +
                "City: \(cityTown!)\n" +
                "State: \(state!)\n" +
                "Zip Code: \(zipCode!)\n" +
                "Coordinate: latitude: \(coordinate?.latitude) longitude \(coordinate?.longitude)\n" +
                "-----------------------------\n"
    }
}

infix operator =|| { associativity left precedence 100 }
func =|| (var lhs: String, rhs: String?) -> Void {
    lhs = rhs ?? ""
}

/**
 *  Internal model representation of a Place.
 */
struct _EventPlace: EventPlaceConvertible {
    let placeID = Variable("")
    let name = Variable("")
    let streetAddress = Variable("")
    let cityTown = Variable("")
    let state = Variable("")
    let zipCode = Variable("")
    let coordinate: Variable<PlaceCoordinate?> = Variable(nil)
    let detailString = Variable("")
    
    var eventPlace: EventPlace {
        return EventPlace(placeName: name.value, streetAddress: streetAddress.value, cityTown: cityTown.value, state: state.value, zipCode: zipCode.value, coordinate: coordinate.value)
    }
}


// MARK: - Google Place conversion
extension _EventPlace {
    init(googlePlace: FormattedGooglePlace, withPlaceName placeName: String) {
        configureFormattedPlace(withString: googlePlace.formattedAddress) //this needs to be fixed
        placeID.value = googlePlace.placeID
        self.name.value = placeName
    }
}

extension _EventPlace {
    init(prediction: AutoCompleteGooglePrediction) {
        configurePrediction(withString: prediction.attributedFullText.string)
        placeID.value = prediction.placeID
    }
}

//TODO: needs sum serrrious testing
extension _EventPlace {
    
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
