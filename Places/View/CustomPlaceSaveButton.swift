//
//  CustomPlaceSaveButton.swift
//  Places
//
//  Created by Sarah Griffis on 12/7/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import UIKit


class CustomPlaceSaveButton: UIView {
    
    //MARK: Property
    let button: UIButton = {
        let b = UIButton(frame: CGRectZero)
        b.setTitle("SAVE", forState: .Normal)
        b.backgroundColor = UIColor.blackColor()
        b.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        b.titleLabel?.font = PlacesViewStyleCatalog.SaveButtonFont
        return b
    }()
    
    let border: UIView = {
        let n = UIView(frame: CGRectZero)
        n.backgroundColor = UIColor(CGColor: PlacesViewStyleCatalog.BorderColor)
        return n
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
        //SG snapkit
        button.frame = CGRect(x: self.frame.width / 2 - PlacesViewStyleCatalog.SaveButtonWidth / 2, y: self.frame.height / 2 - PlacesViewStyleCatalog.SaveButtonHeight / 2, width: PlacesViewStyleCatalog.SaveButtonWidth, height: PlacesViewStyleCatalog.SaveButtonHeight)
    }
    
    private func setup() -> Void {
        self.addSubview(button)
        self.addSubview(border)
        
        border.snp_makeConstraints { (make) -> Void in
            make.top
                .equalTo(self)
            
            make.right
                .left
                .equalTo(self)
                .inset(PlacesViewStyleCatalog.PlacesSideInset)
            
            make.height.equalTo(PlacesViewStyleCatalog.BorderWidth)
        }
    }
    

}