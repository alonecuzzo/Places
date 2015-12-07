//
//  PlacesAutoCompleteTableViewCellFactory.swift
//  Places
//
//  Created by Jabari Bell on 11/26/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import UIKit


struct PlacesAutoCompleteTableViewCellFactory {
    
    static func itemCellFor(tableView: UITableView, index: Int, item: GooglePlacesDatasourceItem) -> UITableViewCell {
        
        //TODO: Come back and clean up this function a bit
        let cell = tableView.dequeueReusableCellWithIdentifier(item.CellIdentifier)
        
        //TODO: ALSO! We need to measure the height of these cells, if the name is too long and wraps, it breaks the cell dang - my initial vote is not to make the textfield wrap
        
        switch item {
        case let .PlaceCell(place):
            return PlacesAutoCompleteTableViewCellFactory.configureCell(cell!, forPlace: place)
        case .CustomPlaceCell:
            cell?.selectionStyle = UITableViewCellSelectionStyle.None
            return cell as! AddCustomLocationCell
        }
    }
    
    private static func configureCell(var cell: UITableViewCell, forPlace place: _Place) -> UITableViewCell {
        //probably should set this ahead of this function
        //is this the best way to set this cell? why isn't it being dequeed?
        cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: GooglePlacesDatasourceItem.PlaceCell(_Place()).CellIdentifier)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.textLabel?.font = UIFont (name: "HelveticaNeue", size: 16)
        cell.textLabel?.text = place.name.value
        cell.detailTextLabel?.font = UIFont (name: "HelveticaNeue", size: 14)
        cell.detailTextLabel?.text = place.detailString.value
        return cell
    }
}
