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


public struct GooglePlacesSearchViewModel {
    
    typealias Prediction = GMSAutocompletePrediction
    
    //MARK: Property
    public let items: Driver<[GooglePlacesDatasourceItem]>
    private let disposeBag = DisposeBag()
    private let API: GooglePlacesSearchMediator
    
    
    //MARK: Method
    //TODO: Have searchText be observable and convert to driver internally
    init(searchText: Driver<String>, currentCoordinate: Variable<PlaceCoordinate>, service: GooglePlacesSearchMediator, throttleValue: Double, authorizationStatus: Variable<PlacesLocationAuthorizationStatus>) {
        self.API = service
        let API = self.API
        
        self.items = searchText
            .asObservable()
            .skipWhile({_ in
                return authorizationStatus.value != PlacesLocationAuthorizationStatus.Authorized //Make sure to tack on add custom location cell!!!! DO IT!!!
            })
            .asDriver(onErrorJustReturn: "")
            .throttle(throttleValue)
                .distinctUntilChanged()
                .map { query -> Driver<[AutoCompleteGooglePrediction]> in

                    return API.getPredictions(query, coordinate: currentCoordinate.value)
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
        let API = self.API
        let disposeBag = self.disposeBag
        return Observable.create { observer in
            API.getPlace(place.placeID.value).subscribeNext({ googlePlace -> Void in
                observer.onNext(_Place(googlePlace: googlePlace, withPlaceName: place.name.value))
            }).addDisposableTo(disposeBag)
            return NopDisposable.instance
        }
    }
}
