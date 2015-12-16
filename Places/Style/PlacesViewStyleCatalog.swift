//
//  PlacesViewStyleCatalog.swift
//  Places
//
//  Created by Jabari Bell on 11/17/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import UIKit

struct PlacesViewStyleCatalog {
    static let BorderWidth: CGFloat = 0.5
    static let BorderColor = UIColor(red: 0.783922, green: 0.780392, blue: 0.8, alpha: 1.0).CGColor

    
    static let PlacesSideInset: CGFloat = 16
    static let PlacesIconHeight: CGFloat = 22
    
    static let PlacesBorder: CALayer = {
        let c = CALayer()
        c.borderColor = PlacesViewStyleCatalog.BorderColor
        c.borderWidth = PlacesViewStyleCatalog.BorderWidth
        return c
    }()
    
    //Places View
    
    //autocomplete search view
    static let AutoCompleteSearchViewText: String = "Type to search for location"
    static let AutoCompleteSearchViewFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 20)!
    static let AutoCompleteSearchViewHeight: CGFloat = 55
    
    //custom location cell
    static let CustomLocationCellText: String = "Add custom location"
    static let CustomLocationCellFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 20)!
    
    //location results cells
    static let LocationResultsCellFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 16)!
    static let LocationResultsCellDetailFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 14)!
    static let LocationResultsFontColor: UIColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1.0)
    static let LocationResultsRowHeight: CGFloat = 55
    
    //powered by Google view
    static let GoogleViewHeight: CGFloat = 18
    static let GoogleViewWidth: CGFloat = 142.5
    
    //Custom Location View
    
    static let CustomPlaceTableViewHeaderHeight: CGFloat = 55
    static let CustomPlaceTableViewFooterHeight: CGFloat = 75
    static let CustomPlaceTableViewRowHeight: CGFloat = 44
    
    //add custom location header view
    static let CustomLocationHeaderViewText: String = "Add custom location"
    static let CustomLocationHeaderViewFont: UIFont = UIFont (name: "HelveticaNeue-Light", size: 20)!
    
    //save button
    static let SaveButtonFont: UIFont = UIFont(name: "HelveticaNeue-Medium", size: 12)!
    static let SaveButtonHeight: CGFloat = 44
    static let SaveButtonWidth: CGFloat = 160
    
}
