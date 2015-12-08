//
//  PlacesAutoCompleteNavigationController.swift
//  Places
//
//  Created by Jabari Bell on 11/28/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import UIKit
import RxSwift


/**
Convenience function that returns a configured UINavigationController.
 
- parameter customPlace: An optional Place that if exists will populate the CustomPlaceViewController.
 
- parameter onDismissal: The closure that will be called when the user exits from the AutoComplete flow.  ***NOTE*** This will be called at most one times.

- returns: UINavigationController
*/
public func placesAutoCompleteNavigationController(customPlace: Place?, onDismissal: (ExitingEvent) -> Void) -> UINavigationController {
    let disposeBag = CompositeDisposable()
    let rootViewController = PlacesAutoCompleteViewController()
    let navigationController = UINavigationController(rootViewController: rootViewController)
    rootViewController.navigationController?.navigationBarHidden = true
    
    let subscription = rootViewController.exitingEvent.subscribeNext { event -> Void in
        guard let event = event else { return }
        onDismissal(event)
        disposeBag.dispose()
    }
    
    //for now, if we have a custom place, we're going to present custom screen from here
    if let customPlace = customPlace {
        //maybe refactor this, i don't like this knowing about the customplacecell
        PlacesAutoCompletePresenter.sharedPresenter.presentViewControllerForItem(.CustomPlaceCell, fromViewController: rootViewController, customPlace: customPlace.asInternalPlace())
    }
    
    disposeBag.addDisposable(subscription)
    return navigationController
}
