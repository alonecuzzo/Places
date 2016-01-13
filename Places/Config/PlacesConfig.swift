//
//  PlacesConfig.swift
//  Places
//
//  Created by Jabari Bell on 1/4/16.
//  Copyright © 2016 Paperless Post. All rights reserved.
//

import Foundation


struct PlacesAutoCompleteConfig {
    let throttleSpeed: AutoCompleteRequestThrottleSpeed
}


enum PlacesAutoCompleteConfigType {
    case Default, Testing
    
    var config: PlacesAutoCompleteConfig {
        switch self {
        case .Default:
            return PlacesAutoCompleteConfig(throttleSpeed: .Medium)
        case .Testing:
            return PlacesAutoCompleteConfig(throttleSpeed: .Slow)
        }
    }
}


enum AutoCompleteRequestThrottleSpeed: Double {
    case Fast = 0.0, Medium = 0.3, Slow = 1.0
}
