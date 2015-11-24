//
//  PoweredByGoogleView.swift
//  Places
//
//  Created by Sarah Griffis on 11/17/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import UIKit

class CustomFooterView: UIView {
    
    //MARK: Property
    let googleImageView = UIImageView(image: UIImage(named: "poweredByGoogle"))
    
    
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
        googleImageView.alpha = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addSubview(googleImageView)
        googleImageView.frame = CGRect(x: self.frame.maxX - 142.5 - 15, y: self.frame.maxY - 18 - 16, width: 142.5, height: 18)
    }
}
