//
//  PoweredByGoogleView.swift
//  Places
//
//  Created by Sarah Griffis on 11/17/15.
//  Copyright © 2015 Paperless Post. All rights reserved.
//

import Foundation
import UIKit


public class PoweredByGoogleView: UIView {
    
    //MARK: Property
    let googleImageView = UIImageView(image: UIImage(named: "poweredByGoogle"))
    
    
    //MARK: Method
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() -> Void {
        googleImageView.alpha = 0
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        addSubview(googleImageView)
        googleImageView.frame = CGRect(x: self.frame.maxX - PlacesViewStyleCatalog.GoogleViewHeight - PlacesViewStyleCatalog.PlacesSideInset, y: self.frame.maxY - PlacesViewStyleCatalog.GoogleViewHeight - PlacesViewStyleCatalog.PlacesSideInset, width: PlacesViewStyleCatalog.GoogleViewWidth, height: PlacesViewStyleCatalog.GoogleViewHeight)
    }
}
