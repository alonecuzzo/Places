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
    let textfield: UITextField = {
        var textField = UITextField()
        textField.placeholder = "Type to search for location"
        //TODO: Double check that this is thre correct font
        textField.font = UIFont(name: "HelveticaNeue", size: 20)
        return textField
    }()
    
    let searchIcon: UIButton = {
        let searchIcon = UIButton.init(type: UIButtonType.Custom)
        searchIcon.enabled = false
        searchIcon.setImage(UIImage(named: "icon-search"), forState: UIControlState.Disabled)
        searchIcon.setImage(UIImage(named: "icon-x"), forState: UIControlState.Normal)
        return searchIcon
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
        [textfield, searchIcon].forEach { self.addSubview($0) }
        
        border.borderColor = UIColor(red: 0.783922, green: 0.780392, blue: 0.8, alpha: 1.0).CGColor
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Should we use snapkit here?
        border.frame = CGRect(x: 0, y: self.frame.size.height - borderWidth, width:  self.frame.size.width, height: self.frame.size.height)
    }
    
    //why is this in did move to superview?
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        textfield.snp_makeConstraints { make in
            self.setTextFieldConstraints(make)
        }
        
        searchIcon.snp_makeConstraints { make in
            self.setSearchIconConstraints(make)
        }
    }
    
    func setTextFieldConstraints(make: ConstraintMaker) {
        
        make.top
            .left
            .bottom
            .equalTo(self)
            .inset(16)
        
        make.right.equalTo(searchIcon.snp_left).inset(16)
    }
    
    func setSearchIconConstraints(make: ConstraintMaker) {
        
        make.top
            .right
            .bottom
            .equalTo(self)
            .inset(16)
        
        make.height
            .greaterThanOrEqualTo(22)
    }
}
