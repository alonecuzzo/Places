//
//  PlacesLocationManager.swift
//  Places
//
//  Created by Jabari Bell on 11/28/15.
//  Copyright © 2015 Paperless Post. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation


public struct PlaceCoordinate {
    let latitude: Double
    let longitude: Double
}

typealias UIAlertActionHandlerBlock = ((UIAlertAction) -> Void)

class PlacesCoreLocationManager {
    
    //MARK: Property
    private let locationManager: CLLocationManager
    private let disposeBag: DisposeBag = DisposeBag()
    private let alertKey = "internalCoreLocationAlertHasBeenShownDateKey"
    var systemCancelAction: UIAlertActionHandlerBlock?
    private let internalAlertBlock: (PlacesCoreLocationManager) -> Void
    var numberOfDaysUntilNextInternalAlertDisplay = 7 //configurable?
    
    
    //MARK: Method
    init(coordinateReceivedBlock: (coordinate: PlaceCoordinate?) -> Void, internalAlertBlock: (PlacesCoreLocationManager) -> Void) {
        self.locationManager = CLLocationManager()
        self.internalAlertBlock = internalAlertBlock
        let status = CLLocationManager.authorizationStatus()
        
        if status == .NotDetermined {
            if shouldShowInternalAlert() {
                showInternalLocationAlertBlock()
            }
        }
        
        locationManager.rx_didUpdateLocations
            .distinctUntilChanged({ (lhs, rhs) -> Bool in
                return lhs.first?.coordinate.latitude == rhs.first?.coordinate.latitude
                    && lhs.first?.coordinate.longitude == rhs.first?.coordinate.longitude
            })
            .subscribeNext { [weak self] locations -> Void in
                self?.locationManager.stopUpdatingLocation()
                guard let location = locations.first else { return }
                let coordinate = PlaceCoordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                coordinateReceivedBlock(coordinate: coordinate)
            }
            .addDisposableTo(disposeBag)
        
        
        locationManager.rx_didChangeAuthorizationStatus.asObservable().subscribeNext { [weak self] status -> Void in
            //            guard let myStatus = status else { return }
            switch status {
            case CLAuthorizationStatus.Denied, CLAuthorizationStatus.Restricted:
                self?.systemCancelAction?(UIAlertAction()) //we don't need an alert action - change signature
            default:
                self?.startUpdatingLocationIfAuthorized(status)
            }
            
            }.addDisposableTo(disposeBag)
        startUpdatingLocationIfAuthorized(status)
    }
    
    func requestAlwaysAuthorization() -> Void {
        locationManager.requestAlwaysAuthorization()
    }
    
    private func startUpdatingLocationIfAuthorized(status: CLAuthorizationStatus) -> Void {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
}

// MARK: Internal Alert Stuff
extension PlacesCoreLocationManager {
    private func shouldShowInternalAlert() -> Bool {
        guard let date = NSUserDefaults.standardUserDefaults().objectForKey(alertKey) as? NSDate else { return true }
        let elapsedTime = NSDate().timeIntervalSinceDate(date)
        let maxSecondsBeforeRePop = numberOfDaysUntilNextInternalAlertDisplay * 60 * 60 * 24
        return Int(elapsedTime) > maxSecondsBeforeRePop
    }
    
    private func showInternalLocationAlertBlock() -> Void {
        internalAlertBlock(self)
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: alertKey)
    }
}
