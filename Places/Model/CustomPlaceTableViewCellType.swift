//
//  CustomPlaceTableViewCellType.swift
//  Places
//
//  Created by Jabari Bell on 12/7/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import UIKit


enum CustomPlaceTableViewCellType {
    case PlaceName, StreetAddress, City, State, ZipCode
    
    var placeHolder: String {
        switch self {
        case .PlaceName:
            return "Venue Name"
        case .StreetAddress:
            return "Address"
        case .City:
            return "City/Town"
        case .State:
            return "State"
        case .ZipCode:
            return "Zip/ Postal Code"
        }
    }
    
    var returnKeyType: UIReturnKeyType {
        switch self {
        case .ZipCode:
            return .Done
        default:
            return .Next
        }
    }
    
    static let CellIdentifer = "CustomPlaceTableViewCellTypeCellIdentifier"
}

extension CustomPlaceTableViewCellType {
    func cellForCellTypeInTableView(tableView: UITableView, withData data: [CustomPlaceTableViewCellType]) -> CustomLocationTableViewCell? {
        guard let index = data.indexOf(self) else { return nil }
        return tableView.cellForRowAtIndexPath(NSIndexPath(forItem: index, inSection: 0)) as? CustomLocationTableViewCell
    }
}
