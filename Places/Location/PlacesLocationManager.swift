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


enum PlacesLocationAuthorizationStatus: Int {
    case Unknown, Authorized, Denied
}

public struct PlaceCoordinate {
    let latitude: Double
    let longitude: Double
}

typealias UIAlertActionHandlerBlock = ((UIAlertAction) -> Void)

class PlacesCoreLocationManager {
    
    //MARK: Property
    private let locationManager: CLLocationManager
    private let disposeBag = DisposeBag()
    
    var authorizationStatus: Variable<PlacesLocationAuthorizationStatus> = {
        return Variable(PlacesCoreLocationManager.internalAuthorizationStatusFromCoreLocationAuthorizationStatus(CLLocationManager.authorizationStatus()))
    }()
    
    private class func internalAuthorizationStatusFromCoreLocationAuthorizationStatus(status: CLAuthorizationStatus) -> PlacesLocationAuthorizationStatus {
        switch status {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            return .Authorized
        case .Denied, .Restricted:
            return .Denied
        default:
            return .Unknown
        }
    }

    
    //MARK: Method
    init(coordinateReceivedBlock: (coordinate: PlaceCoordinate?) -> Void) {
        self.locationManager = CLLocationManager()
    
        requestWhenInUseAuthorization()
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
        
        //TODO: Cleanup
        locationManager.rx_didChangeAuthorizationStatus.asObservable().subscribeNext { [weak self] status -> Void in
            if status != CLAuthorizationStatus.Denied && status != CLAuthorizationStatus.Restricted {
                self?.startUpdatingLocationIfAuthorized(status)
            }
            
            self?.authorizationStatus.value = PlacesCoreLocationManager.internalAuthorizationStatusFromCoreLocationAuthorizationStatus(status)
            
            }.addDisposableTo(disposeBag)
        
        let status = CLLocationManager.authorizationStatus()
        startUpdatingLocationIfAuthorized(status)
    }
    
    func requestWhenInUseAuthorization() -> Void {
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func startUpdatingLocationIfAuthorized(status: CLAuthorizationStatus) -> Void {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
}
