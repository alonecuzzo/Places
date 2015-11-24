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


public enum GooglePlacesDatasourceItem {
    case PlaceCell(Place)
    case CustomPlaceCell
}


public struct GooglePlacesSearchViewModel {
    
    //MARK: Property
    
    //we want an object to wrap the datasource options
    //can either be a place or a custom place
    public let items: Driver<[GooglePlacesDatasourceItem]>
    private let disposeBag = DisposeBag()
    
    
    //MARK: Method
    public init(searchText: Driver<String>, currentLocation: Variable<CLLocation>, service: GooglePlacesSearchable) {
    
        let API = service //now we can pass whatever service in we want - need to give it a protocol assignment
        self.items = searchText
//                .throttle(0.3, MainScheduler.sharedInstance) //need to uncomment for tests, is there an IFDEF thingy we can use to check to see if it's the main app or tests?
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
                    var tmp = results.map { GooglePlacesDatasourceItem.PlaceCell(Place(prediction: $0)) }
                    tmp.append(GooglePlacesDatasourceItem.CustomPlaceCell)
                    return tmp
                }
    }
}
