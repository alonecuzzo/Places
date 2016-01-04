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
    static func placesAutoCompleteNavigationController(customPlace: Place?, externalAlertConfig: PlacesCoreLocationExternalAlertConfig=PlacesCoreLocationAlertExternalConfigType.Default.config, onDismissal: (ExitingEvent) -> Void) -> UINavigationController {
        let disposeBag = CompositeDisposable()
        let rootViewController = PlacesAutoCompleteViewController(externalAlertTitle: externalAlertConfig.externalAlertTitle, externalAlertMessage: externalAlertConfig.externalAlertMessage)
        let navigationController = UINavigationController(rootViewController: rootViewController)
        rootViewController.navigationController?.navigationBarHidden = true
        
        let subscription = rootViewController.exitingEvent.asObservable().subscribeNext { event -> Void in
            guard let event = event else { return }
            onDismissal(event)
            disposeBag.dispose()
        }
        
        if let customPlace = customPlace {
            PlacesAutoCompletePresenter.sharedPresenter.presentCustomPlaceViewControllerFromViewController(rootViewController, withCustomPlace: customPlace.asInternalPlace())
        }
        
        disposeBag.addDisposable(subscription)
        return navigationController
    }
    
    struct PlacesCoreLocationExternalAlertConfig {
        let externalAlertTitle: String
        let externalAlertMessage: String
    }
    
    enum PlacesCoreLocationAlertExternalConfigType {
        case Default
        var config: PlacesCoreLocationExternalAlertConfig {
            switch self {
            case .Default:
                return PlacesCoreLocationExternalAlertConfig(externalAlertTitle: "Can we get your location?", externalAlertMessage: "We need this!")
            }
        }
    }
}
