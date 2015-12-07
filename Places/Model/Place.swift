//
//  Place.swift
//  Places
//
//  Created by Jabari Bell on 11/17/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
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
extension Place: CustomStringConvertible {
    
    public var description: String {
        return "-----------------------------\n" +
                "Place Name: \(placeName!)\n" +
                "Street Address: \(streetAddress!)\n" +
                "State: \(state!)\n" +
                "Zip Code: \(zipCode!)\n" +
                "-----------------------------\n"
    }
}

/**
 *  Internal model representation of a Place.
 */
struct _Place {
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
    func asPlace() -> Place {
        return Place(placeName: name.value, streetAddress: streetAddress.value, cityTown: cityTown.value, state: state.value, zipCode: zipCode.value)
    }
}

// MARK: - Google Place conversion
extension _Place {
    init(googlePlace: GMSPlace) {
        configure(withString: googlePlace.formattedAddress)
        placeID.value = googlePlace.placeID
    }
}

extension _Place {
    init(prediction: GMSAutocompletePrediction) {
        configure(withString: prediction.attributedFullText.string)
        placeID.value = prediction.placeID
    }
}

extension _Place {
    func configure(withString addressString: String) -> Void {
        func offsetIsValid(offset: Int, arrayLength: Int) -> Bool {
            return (arrayLength - offset) > 0
        }
        
        func valueForOffset(offset: Int, array: [String]) -> String {
            return offsetIsValid(offset, arrayLength: array.count) ? array[array.count - offset] : ""
        }
        
        let addressElements = addressString.componentsSeparatedByString(",")
        detailString.value = addressElements[1..<addressElements.count].joinWithSeparator(", ")
        state.value = valueForOffset(2, array: addressElements)
        cityTown.value = valueForOffset(3, array: addressElements)
        streetAddress.value = valueForOffset(4, array: addressElements)
        name.value = addressElements.first ?? ""
    }
}
