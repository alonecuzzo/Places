//
//  PlacesAutoCompleteNavigationController.swift
//  Places
//
//  Created by Jabari Bell on 11/28/15.
//  Copyright © 2015 Paperless Post. All rights reserved.
//

import UIKit
import RxSwift

public struct PlacesAutoCompleteFlow {
    
    /**
    Convenience function that returns a configured UINavigationController.
     
    - parameter customPlace: An optional Place that if exists will populate the CustomPlaceViewController.
     
    - parameter onDismissal: The closure that will be called when the user exits from the AutoComplete flow.  ***NOTE*** This will be called at most one times.

    - returns: UINavigationController
    */
    static func placesAutoCompleteNavigationController(customPlace: Place?, autoCompleteConfig: PlacesAutoCompleteConfig=PlacesAutoCompleteConfigType.Default.config, onDismissal: (ExitingEvent) -> Void) -> UINavigationController {
        
        let disposeBag = CompositeDisposable()
        
        let rootViewController = PlacesAutoCompleteViewController(autoCompleteConfig: autoCompleteConfig)
        let navigationController = UINavigationController(rootViewController: rootViewController)
        rootViewController.navigationController?.navigationBarHidden = true
        
        let subscription = rootViewController.exitingEvent.asObservable().subscribeNext { event -> Void in
            guard let event = event else { return }
            onDismissal(event)
            disposeBag.dispose()
        }
        
        if let customPlace = customPlace {
            let presenter = PlacesAutoCompletePresenter()
            presenter.presentCustomPlaceViewControllerFromViewController(rootViewController, withCustomPlace: customPlace.asInternalPlace())
        }
        
        disposeBag.addDisposable(subscription)
        return navigationController
    }
}
