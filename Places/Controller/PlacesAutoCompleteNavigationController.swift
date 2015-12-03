//
//  PlacesAutoCompleteNavigationController.swift
//  Places
//
//  Created by Jabari Bell on 11/28/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import UIKit
import RxSwift


//make sure to note that this is a single event implementation of the navigation controller
protocol Exitable {
    typealias T
    var exitingEvent: Variable<T> { get }
}


//we want a config that takes an optional place...
func placesAutoCompleteNavigationController(onDismissal: (ExitingEvent) -> Void) -> UINavigationController {
    let disposeBag = CompositeDisposable()
    let rootViewController = PlacesAutoCompleteViewController()
    let navigationController = UINavigationController(rootViewController: rootViewController)
    rootViewController.navigationController?.navigationBarHidden = true
    
    //maybe make an "exitable" protocol
    let subscription = rootViewController.exitingEvent.subscribeNext { event -> Void in
        guard let event = event else { return }
        onDismissal(event)
        disposeBag.dispose() //double check for retain cycle
    }
    disposeBag.addDisposable(subscription)
    return navigationController
}
