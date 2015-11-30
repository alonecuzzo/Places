//
//  GooglePlacesDatasourceItem.swift
//  Places
//
//  Created by Jabari Bell on 11/26/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import UIKit


public enum GooglePlacesDatasourceItem {
    case PlaceCell(Place)
    case CustomPlaceCell
}


extension GooglePlacesDatasourceItem {
    
    var CellIdentifier: String {
        switch self {
        case .PlaceCell(_):
            return "PlaceCellIdentifier"
        case .CustomPlaceCell:
            return "CustomPlaceCellIdentifier"
        }
    }
    
    var cellClass: AnyClass {
        switch self {
        case .PlaceCell(_):
            return UITableViewCell.classForCoder()
        case .CustomPlaceCell:
            return AddCustomLocationCell.classForCoder()
        }
    }
}
