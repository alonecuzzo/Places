//
//  Exitable.swift
//  Places
//
//  Created by Jabari Bell on 12/7/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import RxSwift


protocol Exitable {
    typealias T
    var exitingEvent: Variable<T> { get }
}
