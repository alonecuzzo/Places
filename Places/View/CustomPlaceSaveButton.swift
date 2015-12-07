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
    let button = UIButton(frame: CGRectZero)
    
    
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
        button.setTitle("SAVE", forState: .Normal)
        button.backgroundColor = UIColor.blackColor()
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = UIFont (name: "HelveticaNeue-Medium", size: 12)
        self.addSubview(button)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.frame = CGRect(x: self.frame.width / 2 - 160 / 2, y: self.frame.height / 2 - 44 / 2, width: 160, height: 44)
    }
}