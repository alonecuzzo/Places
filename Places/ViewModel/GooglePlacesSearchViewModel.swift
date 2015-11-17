//
//  GooglePlacesSearchViewModel.swift
//  Places
//
//  Created by Jabari Bell on 11/17/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import GoogleMaps
import CoreLocation


struct GooglePlacesSearchViewModel {
    
    //MARK: Property
    let places: Driver<[Place]>
    let disposeBag = DisposeBag()
    
    
    //MARK: Method
    init(searchText: Driver<String>, currentLocation: Variable<CLLocation>, service: GooglePlacesSearchable) {
    
        let API = service //now we can pass whatever service in we want - need to give it a protocol assignment
        self.places = searchText
                .throttle(0.3, MainScheduler.sharedInstance)
//                .debug("before")
                .distinctUntilChanged()
//                .debug("after")
                .map { query -> Driver<[GMSAutocompletePrediction]>in
                    print("calling api")
                    return API.getPredictions(query, location: currentLocation.value)
                    .retry(3)
                    .startWith([])
                    .asDriver(onErrorJustReturn: [])
                }
                .switchLatest()
                .map { results in
                    results.map {
                        Place(prediction: $0)
                    }
                }
    }
}