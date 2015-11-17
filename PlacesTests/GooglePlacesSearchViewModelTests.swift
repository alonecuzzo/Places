//
//  GooglePlacesSearchViewModelTests.swift
//  Places
//
//  Created by Jabari Bell on 11/13/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import CoreLocation
import GoogleMaps

import Places

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
        
        let fakeRequest = FakeSearchRequest(query: "Some Query", location: paperlessPostLocation)
        let searchTextVar = Variable("")
        let searchTextDriver = searchTextVar.asDriver(onErrorJustReturn: "error")
        
        let locationVariable = Variable(fakeRequest.location)
        let spyService = GooglePlacesSearchServiceSpy()
        let vm = GooglePlacesSearchViewModel(searchText: searchTextDriver, currentLocation: locationVariable, service: spyService)
        
        //make the search text driver hot
        searchTextDriver.asObservable().subscribeNext {_ in }.addDisposableTo(disposeBag)
        
        searchTextVar.value = fakeRequest.query
        
        vm.places.asObservable().subscribeNext { place -> Void in
            print("fake requests: \(spyService.requests)")
            guard let request = spyService.requests.first else {
                //fail
                XCTFail()
                return
            }
            
            print("debugz... fake request query: \(fakeRequest.query), captured request query: \(request.query)")
            print("fake request location: \(fakeRequest.location), capture request location: \(request.location)")
            
            print("are they equal?? \(request.query == fakeRequest.query && request.location == fakeRequest.location)")
            XCTAssert(request.query == fakeRequest.query && request.location == fakeRequest.location)
            
        }.addDisposableTo(disposeBag)
        
    }
    
    
    
    class GooglePlacesSearchServiceSpy: GooglePlacesSearchable {
        
        //MARK: Property
        var requests = [FakeSearchRequest]()
        
        
        //MARK: Method
        func getPredictions(query: String, location: CLLocation) -> Observable<[GMSAutocompletePrediction]> {
            
            GMSAutocompletePrediction(
            
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
