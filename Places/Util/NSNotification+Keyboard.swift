//
//  NSNotification+Keyboard.swift
//  Places
//
//  Created by Jabari Bell on 11/26/15.
//  Copyright © 2015 Paperless Post. All rights reserved.
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