//
//  CustomLocationTableViewCell.swift
//  Places
//
//  Created by Sarah Griffis on 12/7/15.
//  Copyright © 2015 Paperless Post. All rights reserved.
//

import Foundation
import UIKit
import SnapKit


class CustomLocationTableViewCellTextField: UITextField {
    var cellType: CustomPlaceTableViewCellType?
}

class CustomLocationTableViewCell: UITableViewCell {
    
    //MARK: Property

    //SG font color size to stylecatalog
    var textField: CustomLocationTableViewCellTextField = {
        let t = CustomLocationTableViewCellTextField(frame: CGRectZero)
        t.font = PlacesViewStyleCatalog.LocationResultsCellFont
        t.textColor = PlacesViewStyleCatalog.LocationResultsFontColor
        t.autocorrectionType = .No
        return t
    }()
    
    
    //MARK: Method
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        addSubview(textField)
        
        selectionStyle = .None
        
        self.layoutMargins = UIEdgeInsetsZero
        self.separatorInset = UIEdgeInsets(top: 0, left: PlacesViewStyleCatalog.PlacesSideInset, bottom: 0, right: PlacesViewStyleCatalog.PlacesSideInset)
        
        textField.snp_makeConstraints { make in
            make.left
                .equalTo(self)
                .inset(PlacesViewStyleCatalog.PlacesSideInset)
            
            make.centerY
                .equalTo(self)
        }
    }
}
