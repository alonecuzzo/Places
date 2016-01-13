//
//  LocationSettingsPromptView.swift
//  Places
//
//  Created by Sarah Griffis on 1/7/16.
//  Copyright © 2016 Paperless Post. All rights reserved.
//

import Foundation
import UIKit

class LocationSettingsPromptView: UIView {
    
    //MARK: Property
    let button: UIButton = {
        let b = UIButton(frame: CGRectZero)
        b.setTitle("ENABLE LOCATION ACCESS", forState: .Normal)
        b.titleLabel!.font = PlacesViewStyleCatalog.EnableLocationButtonFont
        b.setTitleColor(UIColor.blackColor(), forState: .Normal)
        b.layer.borderColor = UIColor.blackColor().CGColor
        b.layer.borderWidth = PlacesViewStyleCatalog.EnableLocationButtonBorderWidth
        return b
    }()
    
    let text: UILabel = {
        let t = UILabel(frame: CGRectZero)
        t.text = PlacesViewStyleCatalog.EnableLocationTextText
        t.textColor = PlacesViewStyleCatalog.EnableLocationTextFontColor
        t.numberOfLines = 0
        t.font = PlacesViewStyleCatalog.EnableLocationTextFont
        t.textAlignment = NSTextAlignment.Center
        return t
    }()
    
    let icon: UIImageView = {
        let u = UIImageView(image: UIImage(named: "location-icon-large"))
        return u
    }()
    
    
    //MARK: Method
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() -> Void {
        self.addSubview(button)
        self.addSubview(text)
        self.addSubview(icon)
        
        icon.snp_makeConstraints { (make) -> Void in
            make.top
                .equalTo(self)
            
            make.width
                .equalTo(PlacesViewStyleCatalog.EnableLocationIconWidth)
            
            make.height
                .equalTo(PlacesViewStyleCatalog.EnableLocationIconHeight)
            
            make.centerX
                .equalTo(self)
        }
        
        text.snp_makeConstraints { (make) -> Void in
            make.left
                .right
                .equalTo(self)
            
            make.top
                .equalTo(icon.snp_bottom)
                .offset(10)
            
            make.height.equalTo(60)
        }
        
        button.snp_makeConstraints { (make) -> Void in
            make.width
                .equalTo(PlacesViewStyleCatalog.EnableLocationButtonWidth)
            
            make.height
                .equalTo(PlacesViewStyleCatalog.EnableLocationButtonHeight)
            
            make.centerX
                .equalTo(self.center)
            
            make.top
                .equalTo(text.snp_bottom)
                .offset(20)
        }
    }
}
