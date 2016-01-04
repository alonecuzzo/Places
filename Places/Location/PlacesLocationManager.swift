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


typealias UIAlertActionHandlerBlock = ((UIAlertAction) -> Void)

class PlacesCoreLocationManager {
    
    //MARK: Property
    private let locationManager: CLLocationManager
    private let disposeBag = DisposeBag()
    var systemCancelAction: UIAlertActionHandlerBlock?
    private let internalAlertBlock: (PlacesCoreLocationManager) -> Void
    private let locationManagerConfig: PlacesCoreLocationConfig
    
    
    //MARK: Method
    init(coordinateReceivedBlock: (coordinate: PlaceCoordinate?) -> Void, internalAlertBlock: (PlacesCoreLocationManager) -> Void, config: PlacesCoreLocationConfig=PlacesCoreLocationConfigType.Default.config) {
        self.locationManager = CLLocationManager()
        self.internalAlertBlock = internalAlertBlock
        self.locationManagerConfig = config
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
        guard let date = NSUserDefaults.standardUserDefaults().objectForKey(locationManagerConfig.userDefaultsKey) as? NSDate else { return true }
        let elapsedTime = NSDate().timeIntervalSinceDate(date)
        let maxSecondsBeforeRePop = locationManagerConfig.numberOfDaysUntilNextInternalAlertDisplay * 60 * 60 * 24
        return Int(elapsedTime) > maxSecondsBeforeRePop
    }
    
    private func showInternalLocationAlertBlock() -> Void {
        internalAlertBlock(self)
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: locationManagerConfig.userDefaultsKey)
    }
}

struct PlacesCoreLocationConfig {
    let userDefaultsKey: String
    let numberOfDaysUntilNextInternalAlertDisplay: Int
}

enum PlacesCoreLocationConfigType {
    case Default
    var config: PlacesCoreLocationConfig {
        switch self {
        case .Default:
            return PlacesCoreLocationConfig(userDefaultsKey: "internalCoreLocationAlertHasBeenShownDateKey", numberOfDaysUntilNextInternalAlertDisplay: 7)
        }
    }
}

public struct PlaceCoordinate {
    let latitude: Double
    let longitude: Double
}
