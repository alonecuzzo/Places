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
    
    typealias Prediction = GMSAutocompletePrediction
    
    //MARK: Property
    public let items: Driver<[GooglePlacesDatasourceItem]>
    private let disposeBag = DisposeBag()
    private let API: GooglePlacesSearchMediator
    
    
    //MARK: Method
    public init(searchText: Driver<String>, currentLocation: Variable<CLLocation>, service: GooglePlacesSearchMediator) {
        self.API = service
        let API = self.API
        self.items = searchText
//                .throttle(0.3, MainScheduler.sharedInstance) //need to uncomment for tests, is there an IFDEF thingy we can use to check to see if it's the main app or tests?
                .distinctUntilChanged()
                .map { query -> Driver<[AutoCompleteGooglePrediction]> in
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
    
    public func getPlace(place: _Place) -> Observable<_Place> {
//    public func getPlace(placeID: String) -> Observable<_Place> {
        let API = self.API
        let disposeBag = self.disposeBag
        return create { observer in
            API.getPlace(place.placeID.value).subscribeNext({ googlePlace -> Void in
                observer.onNext(_Place(googlePlace: googlePlace, withPlaceName: place.name.value))
            }).addDisposableTo(disposeBag)
            return NopDisposable.instance
        }
    }
}
