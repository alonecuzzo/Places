//
//  CustomLocationTableViewCell.swift
//  Places
//
//  Created by Sarah Griffis on 12/7/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class CustomLocationTableViewCell: UITableViewCell {
    
    //MARK: Property
    var textField = UITextField(frame: CGRectZero)
    
    
    //MARK: Method
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        addSubview(textField)
        textField.font = UIFont (name: "HelveticaNeue", size: 16)
        selectionStyle = .None
        textField.snp_makeConstraints { make in
            make.left
                .equalTo(self)
                .inset(16)
            
            make.centerY
                .equalTo(self)
        }
    }
}
