//
//  GooglePlacesSearchViewModelTests.swift
//  Places
//
//  Created by Jabari Bell on 11/13/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import XCTest
@testable import Places
import RxSwift
import RxCocoa
import CoreLocation
import GoogleMaps


//To test, given a location, our array of places should be what we expect
//going to need to be able to swap out the service -> maybe extract it into another class
//apiForViewModel? will allow for plug & play


//TEST - service
//1. that the proper request is sent to the service

//TEST - viewmodel
//1. that it updates the places array
//2. that it handles an error from the service properly
//3. that it handles an error converting to a Place properly
class GooglePlacesSearchViewModelTests: XCTestCase {
    
    let disposeBag = DisposeBag()

    private let paperlessPostLocation = CLLocation(latitude: 40.708882, longitude: -74.0136213)
}

//service oriented stuff
extension GooglePlacesSearchViewModelTests {
    
    func testThatExpectedParamsAreSentToServiceViaViewModel() {
        let searchText = "Some Search Texts"
        let searchTextVariable = Variable(searchText)
        let searchTextDriver = searchTextVariable.asDriver(onErrorJustReturn: "error")
        
        
        let locationVariable = Variable(paperlessPostLocation)
        let spyService = GooglePlacesSearchServiceSpy()
        _ = GooglePlacesSearchViewModel(searchText: searchTextDriver, currentLocation: locationVariable, service: spyService)
        //subsribe?
//        searchTextDriver = "something else"
        
        searchTextDriver.asObservable().subscribeNext { (result) -> Void in
            print("lolz \(result)")
            
            
        }.addDisposableTo(disposeBag)
        searchTextVariable.value = "something else"
    }
    
    class GooglePlacesSearchServiceSpy: GooglePlacesSearchable {
        
        var requests = [FakeSearchRequest]()
        
        func getResults(query: String, location: CLLocation) -> Observable<[GMSAutocompletePrediction]> {
            
            print("HELLO!?  \(query)")
            
            requests.append(FakeSearchRequest(query: query, location: location))
            return create { observer in
                observer.on(Event.Next([GMSAutocompletePrediction()]))
                observer.on(Event.Completed)
                return NopDisposable.instance
            }
        }
    }
    
    struct FakeSearchRequest {
        let query: String
        let location: CLLocation
    }
}
