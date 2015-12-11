//
//  AddCustomLocationCell.swift
//  Places
//
//  Created by Sarah Griffis on 11/17/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import UIKit


public class AddCustomLocationCell: UITableViewCell {
    
    //MARK: Property
    let cellText = PlacesViewStyleCatalog.CustomLocationCellText
    let pencilImageView = UIImageView(image: UIImage(named: "icon-pencil"))
    let border = PlacesViewStyleCatalog.PlacesBorder
    
    
    //MARK: Method
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        //SG fix with snapkit?
        border.frame = CGRect(x: PlacesViewStyleCatalog.PlacesSideInset,
            y: self.frame.size.height - PlacesViewStyleCatalog.BorderWidth,
            width:  self.frame.size.width - PlacesViewStyleCatalog.PlacesSideInset - PlacesViewStyleCatalog.PlacesSideInset,
            height: self.frame.size.height)

    }
    
    private func setup() -> Void {
        
        self.textLabel!.text = cellText
        self.textLabel?.font = PlacesViewStyleCatalog.CustomLocationCellFont
        
        addSubview(pencilImageView)
        
        pencilImageView.snp_makeConstraints { (make) -> Void in
            
            make.right
                .equalTo(self)
                //SG inset to catalog
                .inset(PlacesViewStyleCatalog.PlacesSideInset)
            
            make.height
                //SG inset to catalog
                .equalTo(PlacesViewStyleCatalog.PlacesIconHeight)
            
            make.centerY
                .equalTo(self)
        }
        
        layer.addSublayer(border)
        layer.masksToBounds = true
    }
}
