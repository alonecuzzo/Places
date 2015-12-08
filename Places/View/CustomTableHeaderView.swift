//
//  CustomTableHeaderView.swift
//  Places
//
//  Created by Sarah Griffis on 12/7/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import UIKit


class CustomTableHeaderView: UIView {
    
    //MARK: Property
    let label = UILabel(frame: CGRectZero)
    let backbutton = UIButton(frame: CGRectZero)
    let border = CALayer()
    let width: CGFloat = 0.8
    
    
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
        label.text =  "Add custom location"
        label.textAlignment = .Center
        backbutton.setImage(UIImage(named: "icon-backArrow-black"), forState: UIControlState.Normal)
        addSubview(label)
        addSubview(backbutton)
        border.borderColor = UIColor(red: 0.783922, green: 0.780392, blue: 0.8, alpha: 1.0).CGColor
        border.borderWidth = width
        layer.addSublayer(border)
        layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = self.frame
        backbutton.frame = CGRect(x: 16, y: 0, width: 20, height: self.frame.height)
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
    }
}
