//
//  NSNotification+Keyboard.swift
//  Places
//
//  Created by Jabari Bell on 11/26/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import UIKit

extension NSNotification {
    var keyboardFrame: CGRect? {
        get {
            return (self.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
        }
    }
}