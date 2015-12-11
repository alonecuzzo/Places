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
        var tf = UITextField()
        tf.placeholder = PlacesViewStyleCatalog.AutoCompleteSearchViewText
        tf.font = PlacesViewStyleCatalog.AutoCompleteSearchViewFont
        tf.autocorrectionType = .No
        tf.autocapitalizationType = .None
        return tf
    }()
    
    let searchIcon: UIButton = {
        let si = UIButton.init(type: UIButtonType.Custom)
        si.enabled = false
        si.setImage(UIImage(named: "icon-search"), forState: UIControlState.Disabled)
        si.setImage(UIImage(named: "icon-x"), forState: UIControlState.Normal)
        return si
    }()
    
    let border = PlacesViewStyleCatalog.PlacesBorder
    
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
//        border.frame = CGRect(x: 0, y: self.frame.size.height - PlacesViewStyleCatalog.BorderWidth, width:  self.frame.size.width, height: PlacesViewStyleCatalog.BorderWidth)
        
        border.frame = CGRect(x:0, y:0, width:self.frame.size.width, height: 0.8)
        
        self.backgroundColor = 
        

    }
    
    private func setup() -> Void {
        
        addSubview(textField)
        addSubview(searchIcon)
        
        textField.snp_makeConstraints { make in
            make.top
                .left
                .bottom
                .equalTo(self)
                .inset(PlacesViewStyleCatalog.PlacesSideInset)
            
            make.right.equalTo(searchIcon.snp_left).inset(PlacesViewStyleCatalog.PlacesSideInset)
        }
        
        searchIcon.snp_makeConstraints { make in
            make.top
                .right
                .bottom
                .equalTo(self)
                .inset(PlacesViewStyleCatalog.PlacesSideInset)
            
            make.height
                .greaterThanOrEqualTo(PlacesViewStyleCatalog.PlacesSideInset)
        }
        
        layer.masksToBounds = true
        layer.addSublayer(border)

    }
}
