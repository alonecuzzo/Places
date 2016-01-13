//
//  GooglePlacesSearchViewModel.swift
//  Places
//
//  Created by Jabari Bell on 11/17/15.
//  Copyright © 2015 Paperless Post. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import GoogleMaps


struct GooglePlacesSearchViewModel {
    
    typealias Prediction = GMSAutocompletePrediction
    
    //MARK: Property
    let items: Driver<[GooglePlacesDatasourceItem]>
    private let disposeBag = DisposeBag()
    private let API: GooglePlaceSearchable
    
    
    //MARK: Method
    init(searchText: Observable<String>, currentCoordinate: Variable<PlaceCoordinate>, service: GooglePlaceSearchable, throttleValue: Double, authorizationStatus: Variable<PlacesLocationAuthorizationStatus>) {
        self.API = service
        let API = self.API
        
        self.items = searchText
            .asDriver(onErrorJustReturn: "")
            .throttle(throttleValue)
            .distinctUntilChanged() //what does this do?
            .map { query -> Driver<[AutoCompleteGooglePrediction]> in
                return API.getPredictions(query, coordinate: currentCoordinate.value, authorizationStatus: authorizationStatus)
                .retry(3)
                .startWith([])
                .asDriver(onErrorJustReturn: [])
            }
            .switchLatest() //what does this do?
            .map { results in
                var tmp = results.map { GooglePlacesDatasourceItem.PlaceCell(_EventPlace(prediction: $0)) }
                tmp.append(GooglePlacesDatasourceItem.CustomPlaceCell)
                return tmp
            }
    }
    
    public func getPlace(place: _EventPlace) -> Observable<_EventPlace> {
        let API = self.API
        let disposeBag = self.disposeBag
        return Observable.create { observer in
            API.getPlace(place.placeID.value).subscribeNext({ googlePlace -> Void in
                observer.onNext(_EventPlace(googlePlace: googlePlace, withPlaceName: place.name.value))
            }).addDisposableTo(disposeBag)
            return NopDisposable.instance
        }
    }
}
