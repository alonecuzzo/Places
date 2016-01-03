//
//  Operators.swift
//  Places
//
//  Created by Jabari Bell on 11/28/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


///Double Bind
infix operator <-> {
}

func <-> <T>(property: ControlProperty<T>, variable: Variable<T>) -> Disposable {
    let bindToUIDisposable = variable.asObservable()
        .bindTo(property)
    let bindToVariable = property
        .subscribe(onNext: { n in
            variable.value = n
        }, onCompleted:  {
            bindToUIDisposable.dispose()
        })

    return StableCompositeDisposable.create(bindToUIDisposable, bindToVariable)
}
