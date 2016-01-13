//
//  AddCustomLocationCell.swift
//  Places
//
//  Created by Sarah Griffis on 11/17/15.
//  Copyright © 2015 Paperless Post. All rights reserved.
//

import Foundation
import UIKit


public class AddCustomLocationCell: UITableViewCell {
    
    //MARK: Property
    let cellText = PlacesViewStyleCatalog.CustomLocationCellText
    let pencilImageView = UIImageView(image: UIImage(named: "icon-pencil"))
    
    //MARK: Method
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() -> Void {
        
        self.textLabel!.text = cellText
        self.textLabel?.font = PlacesViewStyleCatalog.CustomLocationCellFont
        
        self.layoutMargins = UIEdgeInsetsZero
        self.separatorInset = UIEdgeInsets(top: 0, left: PlacesViewStyleCatalog.PlacesSideInset, bottom: 0, right: PlacesViewStyleCatalog.PlacesSideInset)
        
        addSubview(pencilImageView)
        
        pencilImageView.snp_makeConstraints { (make) -> Void in
            
            make.right
                .equalTo(self)
                .inset(PlacesViewStyleCatalog.PlacesSideInset)
            
            make.height
                .equalTo(PlacesViewStyleCatalog.PlacesIconHeight)
            
            make.centerY
                .equalTo(self)
        }
        
    }
}
