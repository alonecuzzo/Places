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


public struct GooglePlacesSearchViewModel {
    
    //MARK: Property
    let items: Driver<[GooglePlacesDatasourceItem]>
    private let disposeBag = DisposeBag()
    private let API: GoogleSearchable
    
    public typealias GoogleSearchable = protocol<GooglePlaceSearchable, GooglePlacesSearchable>
    
    
    //MARK: Method
    public init(searchText: Driver<String>, currentLocation: Variable<CLLocation>, service: GoogleSearchable) {
        self.API = service
        let API = self.API
        self.items = searchText
//                .throttle(0.3, MainScheduler.sharedInstance) //need to uncomment for tests, is there an IFDEF thingy we can use to check to see if it's the main app or tests?
                .distinctUntilChanged()
                .map { query -> Driver<[GMSAutocompletePrediction]> in
                    print("calling api")
                    return API.getPredictions(query, location: currentLocation.value)
                    .retry(3)
                    .startWith([])
                    .asDriver(onErrorJustReturn: [])
                }
                .switchLatest()
                .map { results in
                    var tmp = results.map { GooglePlacesDatasourceItem.PlaceCell(_Place(prediction: $0)) }
                    tmp.append(GooglePlacesDatasourceItem.CustomPlaceCell)
                    return tmp
                }
    }
    
    func getPlace(placeID: String) -> Observable<_Place> {
        let API = self.API
        let disposeBag = self.disposeBag
        return create { observer in
            API.getPlace(placeID).subscribeNext({ googlePlace -> Void in
                observer.onNext(_Place(googlePlace: googlePlace))
            }).addDisposableTo(disposeBag)
            return NopDisposable.instance
        }
    }
}
