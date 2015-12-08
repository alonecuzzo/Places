//
//  LocationSearchView.swift
//  Places
//
//  Created by Sarah Griffis on 11/17/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import SnapKit


class PlacesAutoCompleteSearchView: UIView {
    
    //MARK: Property
    let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Type to search for location"
        tf.font = UIFont(name: "HelveticaNeue", size: 20)
        return tf
    }()
    
    let searchIcon: UIButton = {
        let si = UIButton.init(type: UIButtonType.Custom)
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
    
    private func setup() {
        addSubview(textField)
        addSubview(searchIcon)
        
        border.borderColor = UIColor(red: 0.783922, green: 0.780392, blue: 0.8, alpha: 1.0).CGColor
        border.borderWidth = borderWidth
        layer.addSublayer(border)
        layer.masksToBounds = true
        
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
