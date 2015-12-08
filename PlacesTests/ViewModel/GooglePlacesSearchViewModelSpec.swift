//
//  GooglePlacesSearchViewModelSpec.swift
//  Places
//
//  Created by Jabari Bell on 12/7/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import Quick
import Nimble
import GoogleMaps
import RxSwift

import Places

//let fakeRequest = FakeSearchRequest(query: "Some Query", location: paperlessPostLocation)
//let searchTextVar = Variable("")
//let searchTextDriver = searchTextVar.asDriver(onErrorJustReturn: "error")
//
//let locationVariable = Variable(fakeRequest.location)
//let spyService = GooglePlacesSearchServiceSpy()
//let vm = GooglePlacesSearchViewModel(searchText: searchTextDriver, currentLocation: locationVariable, service: spyService)
//
////make the search text driver hot
//searchTextDriver.asObservable().subscribeNext {_ in }.addDisposableTo(disposeBag)
//
//searchTextVar.value = fakeRequest.query
//
//vm.places.asObservable().subscribeNext { place -> Void in
//    print("fake requests: \(spyService.requests)")
//    guard let request = spyService.requests.first else {
//        //fail
//        XCTFail()
//        return
//    }
//    
//    print("debugz... fake request query: \(fakeRequest.query), captured request query: \(request.query)")
//    print("fake request location: \(fakeRequest.location), capture request location: \(request.location)")
//    
//    print("are they equal?? \(request.query == fakeRequest.query && request.location == fakeRequest.location)")
//    XCTAssert(request.query == fakeRequest.query && request.location == fakeRequest.location)
//    
//    }.addDisposableTo(disposeBag)

let paperlessPostLocation = Variable(CLLocation(latitude: 40.708882, longitude: -74.0136213))

class GooglePlacesSearchViewModelSpec: QuickSpec {
    
    
    override func spec() {
        let disposeBag = DisposeBag()
        describe("user typing into auto complete search field") {
            
            it("search using the expected query") {
                let queryString = "LolCatz"
                let query = Variable(queryString).asDriver(onErrorJustReturn: "")
                let spyService = GooglePlacesSearchServiceSpy()
                
                query.asObservable().subscribeNext { _ in }.addDisposableTo(disposeBag) //make signal hot
                
                let vm = GooglePlacesSearchViewModel(searchText: query, currentLocation: paperlessPostLocation, service: spyService)
                vm.items.asObservable().subscribe { (event) -> Void in
                    switch event {
                    case .Next(_):
                        guard let capturedRequest = spyService.requests.first else { fail(); break }
                        expect(capturedRequest.query).to(equal(queryString))
                    case .Error:
                        fail("failed with query: \(query)")
                    default:
                        break
                    }
                }.addDisposableTo(disposeBag)
                
            }
            
        }
    }
}

public typealias GoogleSearchable = protocol<GooglePlaceSearchable, GooglePlacesSearchable>
class GooglePlacesSearchServiceSpy: GoogleSearchable {
    
    //MARK: Property
    var requests = [FakeSearchRequest]()
    
    
    //MARK: Method
    func getPredictions(query: String, location: CLLocation) -> Observable<[GMSAutocompletePrediction]> {
        requests.append(FakeSearchRequest(query: query, location: location))
        return just([FakeAutoCompletePrediction(attributedString: NSAttributedString(string: ""))])
    }
    
    func getPlace(placeID: String) -> Observable<GMSPlace> {
       return just(GMSPlace())
    }
    
}


//now create some fake predictions and all that jazz

class FakeAutoCompletePrediction: GMSAutocompletePrediction {
    
    let test_attributedString: NSAttributedString
    
    init(attributedString :NSAttributedString) {
        self.test_attributedString = attributedString
//        super.init()
    }
}

struct FakeSearchRequest {
    let query: String
    let location: CLLocation
}
