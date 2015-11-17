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


//model for our places of interest - might take Variable out and make just strings, maybe optional vars?
struct Place {
    let name = Variable("")
    let streetAddress = Variable("")
    let cityTown = Variable("")
    let state = Variable("")
    let country = Variable("")
    let detailString = Variable("") //for the detail label in the cell
}


//google maps extension
extension Place {
    init(prediction: GMSAutocompletePrediction) {
        //is the title always the first string? what if there's no title
        func offsetIsValid(offset: Int, arrayLength: Int) -> Bool {
            return (arrayLength - offset) > 0
        }
        
        func valueForOffset(offset: Int, array: [String]) -> String {
            return offsetIsValid(offset, arrayLength: array.count) ? array[array.count - offset] : ""
        }
        //TODO: Double check google places docs on how to parse this - also what is the street number for the address?
        let predictionFullString = prediction.attributedFullText.string
        let addressElements = predictionFullString.componentsSeparatedByString(",")
        detailString.value = addressElements[1..<addressElements.count].joinWithSeparator(", ")
        country.value = valueForOffset(1, array: addressElements)
        state.value = valueForOffset(2, array: addressElements)
        cityTown.value = valueForOffset(3, array: addressElements)
        streetAddress.value = valueForOffset(4, array: addressElements)
        name.value = addressElements.first ?? ""
    }
}
