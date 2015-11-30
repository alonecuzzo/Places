//
//  UIViewController+Keyboard.swift
//  Places
//
//  Created by Jabari Bell on 11/26/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

extension UIViewController {
    func onKeyboardDidShow(block: (notification: NSNotification) -> ()) -> Disposable {
        return NSNotificationCenter.defaultCenter().rx_notification(UIKeyboardDidShowNotification, object: nil).subscribeNext { (note) -> Void in
            block(notification: note)
        }
    }
    
    func onKeyboardDidHide(block: (notification: NSNotification) -> ()) -> Disposable {
        return NSNotificationCenter.defaultCenter().rx_notification(UIKeyboardDidHideNotification, object: nil).subscribeNext { (note) -> Void in
            block(notification: note)
        }
    }
}
