//
//  PlacesLocationManager.swift
//  Places
//
//  Created by Jabari Bell on 11/28/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation


class PlacesCoreLocationManager {
    
    //MARK: Property
    private let locationManager: CLLocationManager
    private let disposeBag: DisposeBag
    
    
    //MARK: Method
    init(locationReceivedBlock: (location: CLLocation?) -> Void) {
        self.locationManager = CLLocationManager()
        self.disposeBag = DisposeBag()
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.rx_didUpdateLocations
            .distinctUntilChanged({ (lhs, rhs) -> Bool in
                return lhs.first?.coordinate.latitude == rhs.first?.coordinate.latitude
                        && lhs.first?.coordinate.longitude == rhs.first?.coordinate.longitude
            })
            .subscribeNext { [weak self] locations -> Void in
                self?.locationManager.stopUpdatingLocation()
                locationReceivedBlock(location: locations.first)
            }
            .addDisposableTo(disposeBag)
        locationManager.startUpdatingLocation()
    }
}
