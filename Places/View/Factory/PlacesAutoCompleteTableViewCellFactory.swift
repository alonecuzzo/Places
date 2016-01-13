//
//  PlacesAutoCompleteTableViewCellFactory.swift
//  Places
//
//  Created by Jabari Bell on 11/26/15.
//  Copyright © 2015 Paperless Post. All rights reserved.
//

import Foundation
import UIKit


struct PlacesAutoCompleteTableViewCellFactory {
    
    static func itemCellFor(tableView: UITableView, index: Int, item: GooglePlacesDatasourceItem) -> UITableViewCell {
        
        //TODO: Come back and clean up this function a bit
        let cell = tableView.dequeueReusableCellWithIdentifier(item.cellIdentifier)
        
        switch item {
        case let .PlaceCell(place):
            return PlacesAutoCompleteTableViewCellFactory.configureCell(cell!, forPlace: place)
        case .CustomPlaceCell:
            cell?.selectionStyle = UITableViewCellSelectionStyle.None
            return cell as! AddCustomLocationCell
        }
    }
    
    private static func configureCell(var cell: UITableViewCell, forPlace place: _EventPlace) -> UITableViewCell {
        cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: GooglePlacesDatasourceItem.PlaceCell(_EventPlace()).cellIdentifier)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.textLabel?.font = PlacesViewStyleCatalog.LocationResultsCellFont
        cell.textLabel?.textColor = PlacesViewStyleCatalog.LocationResultsFontColor
        cell.textLabel?.text = place.name.value
        cell.detailTextLabel?.font = PlacesViewStyleCatalog.LocationResultsCellDetailFont
        cell.detailTextLabel?.textColor = PlacesViewStyleCatalog.LocationResultsFontColor
        cell.detailTextLabel?.text = place.detailString.value
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: PlacesViewStyleCatalog.PlacesSideInset, bottom: 0, right: PlacesViewStyleCatalog.PlacesSideInset)

        return cell
    }
}
