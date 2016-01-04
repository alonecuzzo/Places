//
//  PlacesConfig.swift
//  Places
//
//  Created by Jabari Bell on 1/4/16.
//  Copyright © 2016 Code Mitten. All rights reserved.
//

import Foundation


struct PlacesAutoCompleteConfig {
    let alertConfigType:  PlacesCoreLocationAlertExternalConfigType
    let throttleSpeed: ThrottleSpeed
}

enum PlacesAutoCompleteConfigType {
    case Default, Testing
    
    var config: PlacesAutoCompleteConfig {
        switch self {
        case .Default:
            return PlacesAutoCompleteConfig(alertConfigType: PlacesCoreLocationAlertExternalConfigType.Default, throttleSpeed: .Medium)
        case .Testing:
            return PlacesAutoCompleteConfig(alertConfigType: PlacesCoreLocationAlertExternalConfigType.Default, throttleSpeed: .Slow)
        }
    }
}

enum ThrottleSpeed: Double {
    case Fast = 0.0, Medium = 0.3, Slow = 1.0
}

///MARK: External Alert Config
struct PlacesCoreLocationExternalAlertConfig {
    let externalAlertTitle: String
    let externalAlertMessage: String
}

enum PlacesCoreLocationAlertExternalConfigType {
    case Default
    var config: PlacesCoreLocationExternalAlertConfig {
        switch self {
        case .Default:
            return PlacesCoreLocationExternalAlertConfig(externalAlertTitle: "Can we get your location?", externalAlertMessage: "We need this!")
        }
    }
}
