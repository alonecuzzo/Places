//
//  GooglePlacesDatasourceItem.swift
//  Places
//
//  Created by Jabari Bell on 11/26/15.
//  Copyright © 2015 Paperless Post. All rights reserved.
//

import Foundation
import UIKit


enum GooglePlacesDatasourceItem {
    case PlaceCell(_EventPlace)
    case CustomPlaceCell
}

extension GooglePlacesDatasourceItem: CellIdentifiable {
    
    var cellIdentifier: String {
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
