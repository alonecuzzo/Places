//
//  CustomLocationTableViewCell.swift
//  Places
//
//  Created by Sarah Griffis on 12/7/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class CustomLocationTableViewCell: UITableViewCell {
    
    //MARK: Property

    //SG font color size to stylecatalog
    var textField: UITextField = {
        let t = UITextField(frame: CGRectZero)
        t.font = PlacesViewStyleCatalog.LocationResultsCellFont
        t.textColor = PlacesViewStyleCatalog.LocationResultsFontColor
        t.autocorrectionType = .No
        return t
    }()
    
    var border = PlacesViewStyleCatalog.PlacesBorder
    
    //MARK: Method
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        border.frame = CGRect(x: PlacesViewStyleCatalog.PlacesSideInset,
            y: self.frame.size.height - PlacesViewStyleCatalog.BorderWidth,
            width:  self.frame.size.width - PlacesViewStyleCatalog.PlacesSideInset - PlacesViewStyleCatalog.PlacesSideInset,
            height: self.frame.size.height)
    }
    
    private func setup() {
        addSubview(textField)
        
        layer.addSublayer(border)
        layer.masksToBounds = true
        
        selectionStyle = .None
        
        textField.snp_makeConstraints { make in
            make.left
                .equalTo(self)
                .inset(PlacesViewStyleCatalog.PlacesSideInset)
            
            make.centerY
                .equalTo(self)
        }
    }
}
