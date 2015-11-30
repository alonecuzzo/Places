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
    let placeID = Variable("")
    let name = Variable("")
    let streetAddress = Variable("")
    let cityTown = Variable("")
    let state = Variable("")
    let country = Variable("")
    let detailString = Variable("")
    //coordinate?
}

extension Place {
    init(googlePlace: GMSPlace) {
        configure(withString: googlePlace.formattedAddress)
        placeID.value = googlePlace.placeID
    }
}

extension Place {
    init(prediction: GMSAutocompletePrediction) {
        configure(withString: prediction.attributedFullText.string)
        placeID.value = prediction.placeID
    }
}

extension Place {
    func configure(withString addressString: String) -> Void {
        func offsetIsValid(offset: Int, arrayLength: Int) -> Bool {
            return (arrayLength - offset) > 0
        }
        
        func valueForOffset(offset: Int, array: [String]) -> String {
            return offsetIsValid(offset, arrayLength: array.count) ? array[array.count - offset] : ""
        }
        
        let addressElements = addressString.componentsSeparatedByString(",")
        detailString.value = addressElements[1..<addressElements.count].joinWithSeparator(", ")
        country.value = valueForOffset(1, array: addressElements)
        state.value = valueForOffset(2, array: addressElements)
        cityTown.value = valueForOffset(3, array: addressElements)
        streetAddress.value = valueForOffset(4, array: addressElements)
        name.value = addressElements.first ?? ""
    }
}
