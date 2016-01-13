//
//  CustomTableHeaderView.swift
//  Places
//
//  Created by Sarah Griffis on 12/7/15.
//  Copyright © 2015 Paperless Post. All rights reserved.
//

import Foundation
import UIKit


class EventDetailsLocationPickerCustomTableHeaderView: UIView {
    
    //MARK: Property
    let label: UILabel = {
        let l = UILabel(frame: CGRectZero)
        l.text =  PlacesViewStyleCatalog.CustomLocationHeaderViewText
        l.font = PlacesViewStyleCatalog.CustomLocationHeaderViewFont
        l.textAlignment = .Center
        return l
    }()
    
    let backbutton: UIButton = {
        let b = UIButton(frame: CGRectZero)
        b.setImage(UIImage(named: "icon-backArrow-black"), forState: UIControlState.Normal)
        return b
    }()
    
    let border: CALayer = {
        let c = CALayer()
        c.borderColor = PlacesViewStyleCatalog.BorderColor
        c.borderWidth = PlacesViewStyleCatalog.BorderWidth
        return c
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = self.frame
        backbutton.frame = CGRect(x: PlacesViewStyleCatalog.PlacesSideInset, y: 0, width: PlacesViewStyleCatalog.PlacesIconHeight, height: self.frame.height)
        border.frame = CGRect(x: 0, y: self.frame.size.height - PlacesViewStyleCatalog.BorderWidth, width:  self.frame.size.width, height: self.frame.size.height)
    }
    
    private func setup() -> Void {
        addSubview(label)
        addSubview(backbutton)
        layer.addSublayer(border)
        layer.masksToBounds = true
    }
}
