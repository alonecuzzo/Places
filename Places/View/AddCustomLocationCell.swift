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
    let cellText = "Add custom location"
    let pencilImageView = UIImageView(image: UIImage(named: "icon-pencil"))
    
    
    //MARK: Method
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.textLabel!.text = cellText
        self.textLabel?.font = UIFont (name: "HelveticaNeue", size: 20)
        self.setup()
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup() {
        
        addSubview(pencilImageView)
        pencilImageView.snp_makeConstraints { (make) -> Void in
            
            make.right
                .equalTo(self)
                .inset(16)
            
            make.height
                .equalTo(22)
            
            make.centerY
                .equalTo(self)
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        //TODO: clean up - should be in setup()
        let border = CALayer()
        border.borderColor = PlacesViewStyleCatalog.BorderColor
        border.frame = CGRect(x: 16, y: self.frame.size.height - PlacesViewStyleCatalog.BorderWidth, width:  self.frame.size.width - 16 - 16, height: self.frame.size.height)
        
        border.borderWidth = PlacesViewStyleCatalog.BorderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}