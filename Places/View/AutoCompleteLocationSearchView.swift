//
//  AutoCompleteLocationSearchView.swift
//  Places
//
//  Created by Sarah Griffis on 11/26/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import UIKit
import SnapKit



class AutoCompleteLocationSearchView: UIView {
    
    //MARK: Property
    let textField: UITextField = {
        var tf = UITextField()
        tf.placeholder = "Type to search for location"
        tf.font = UIFont(name: "HelveticaNeue", size: 20)
        return tf
    }()
    
    
    let searchIcon: UIButton = {
        let si = UIButton.init(type: UIButtonType.Custom)
        si.enabled = false
        si.setImage(UIImage(named: "icon-search"), forState: UIControlState.Disabled)
        si.setImage(UIImage(named: "icon-x"), forState: UIControlState.Normal)
        return si
    }()
    
    let border = CALayer()
    let borderWidth: CGFloat = 0.8
    
    
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
        border.frame = CGRect(x: 0, y: self.frame.size.height - borderWidth, width:  self.frame.size.width, height: self.frame.size.height)
    }
    
    private func setup() -> Void {
        border.borderWidth = borderWidth
        layer.masksToBounds = true
        layer.addSublayer(border)
        border.borderColor = UIColor(red: 0.783922, green: 0.780392, blue: 0.8, alpha: 1.0).CGColor
        
        addSubview(textField)
        addSubview(searchIcon)
        
        textField.snp_makeConstraints { make in
            make.top
                .left
                .bottom
                .equalTo(self)
                .inset(16)
            
            make.right.equalTo(searchIcon.snp_left).inset(16)
        }
        
        searchIcon.snp_makeConstraints { make in
            make.top
                .right
                .bottom
                .equalTo(self)
                .inset(16)
            
            make.height
                .greaterThanOrEqualTo(22)
        }
    }
}
