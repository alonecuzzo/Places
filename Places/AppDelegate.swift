//
//  AppDelegate.swift
//  Places
//
//  Created by Jabari Bell on 11/2/15.
//  Copyright © 2015 Paperless Post. All rights reserved.
//

import UIKit
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        GMSServices.provideAPIKey("AIzaSyCQj8eAOjVBgdXO9MZEF9I6zzKjSJcssZg")
        
        
//        let place = Place(placeName: "LOL", streetAddress: "23 LOLz Lane", cityTown: "Amsterdam", state: "NY", zipCode: "39482")
        let place :Place? = nil
        
        
        let placesNavigationController = PlacesAutoCompleteFlow.placesAutoCompleteNavigationController(place) { event in
            switch event {
            case let .AutoCompletePlace(place):
                print("exited with autocomplete place event and place:")
                print(place.debugDescription)
            case let .CustomPlace(place):
                print("exited with custom place event and place:")
                print(place.debugDescription)
            case .Cancel:
                print("exited with cancel event")
            }
        }
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = placesNavigationController
        window?.makeKeyAndVisible()
        return true
    }
}

