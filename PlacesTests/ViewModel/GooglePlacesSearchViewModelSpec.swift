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

@testable import Places

let paperlessPostLocation = Variable(CLLocation(latitude: 40.708882, longitude: -74.0136213))

class GooglePlacesSearchViewModelSpec: QuickSpec {
    
    
    override func spec() {
        let disposeBag = DisposeBag()
        
        describe("user typing into auto complete search field") {
            
            it("should search using the expected request") {
                let queryString = fakeAutoCompleteQuery
                let query = Variable(queryString).asDriver(onErrorJustReturn: "")
                let spyService = FakeGoogleSearchService()
                let vm = GooglePlacesSearchViewModel(searchText: query, currentLocation: paperlessPostLocation, service: spyService)
                vm.items.asObservable().subscribe { (event) -> Void in
                    switch event {
                    case .Next(_):
                        guard let capturedRequest = spyService.autoCompleteRequests.first else { fail(); break }
                        expect(capturedRequest.query).to(equal(queryString))
                    case .Error:
                        fail("failed with query: \(query)")
                    default:
                        break
                    }
                }.addDisposableTo(disposeBag)
                
            }
            
            it("should return the expected autocomplete place") {
                let fakeAutoCompletePlaces = fakeAutoCompletePlaceDict[fakeAutoCompleteQuery]!
                let spyService = FakeGoogleSearchService()
                spyService.getPredictions(fakeAutoCompleteQuery, location: paperlessPostLocation.value).subscribeNext({ places -> Void in
                    let place = places.first!
                    let fakePlace = fakeAutoCompletePlaces.first!
                    expect(place.placeID).to(equal(fakePlace.placeID))
                }).addDisposableTo(disposeBag)
            }
        }
        
        describe("user selecting place from the autocomplete table") {
            
//            it("should send up the expected request") {
//                let placeID = fakePlaceID
//                let spyService = FakeGoogleSearchService()
//                let vm = GooglePlacesSearchViewModel(searchText: Variable(fakeAutoCompleteQuery).asDriver(onErrorJustReturn: ""), currentLocation: paperlessPostLocation, service: spyService)
//                vm.getPlace(placeID).subscribe { event -> Void in
//                    switch event {
//                    case .Next(_):
//                        guard let capturedRequest = spyService.placeRequests.first else { fail(); break }
//                        expect(capturedRequest.placeID).to(equal(placeID))
//                    case .Error:
//                        fail("failed with placeID: \(placeID)")
//                    default:
//                        break
//                    }
//                }.addDisposableTo(disposeBag)
//            }
            
            //really a service test
            it("should return the expected place") {
                let fakePlace = fakePlaceDict[fakePlaceID]!
                let spyService = FakeGoogleSearchService()
                spyService.getPlace(fakePlace.placeID).subscribeNext({ place -> Void in
                    expect(fakePlace.placeID).to(equal(place.placeID))
                    expect(fakePlace.formattedAddress).to(equal(place.formattedAddress))
                }).addDisposableTo(disposeBag)
            }
        }

    }
}

class FakeGoogleSearchService: GooglePlacesSearchService {
    
    //MARK: Property
    var autoCompleteRequests = [FakeAutoCompleteSearchRequest]()
    var placeRequests = [FakePlaceSearchRequest]()
    
    override init() {
        super.init()
    }
    
    
    //MARK: Method
    override func getPredictions(query: String, location: CLLocation) -> Observable<[AutoCompleteGooglePrediction]> {
        autoCompleteRequests.append(FakeAutoCompleteSearchRequest(query: query, location: location))
        return just(fakeAutoCompletePlaceDict[query]!)
    }
    
    override func getPlace(placeID: String) -> Observable<FormattedGooglePlace> {
        placeRequests.append(FakePlaceSearchRequest(placeID: placeID))
        return just(fakePlaceDict[placeID]!)
    }
}

struct FakePlaceSearchRequest {
    let placeID: String
}

struct FakeAutoCompleteSearchRequest {
    let query: String
    let location: CLLocation
}

//MARK: Helper
let fakePlaceID = "38395-13893hhdfi-384"
let fakePlaceAddress = "13 Forty Lane"
let fakePlaceDict = [fakePlaceID: FormattedGooglePlace(placeID: fakePlaceID, formattedAddress: fakePlaceAddress)]

let fakeAutoCompleteQuery = "Gimme Some Places"
let fakeAutoCompleteArray = [AutoCompleteGooglePrediction(placeID: "88958353-38hs-111", attributedText: NSAttributedString(string: "This is my SONG MAN"))]
let fakeAutoCompletePlaceDict = [fakeAutoCompleteQuery: fakeAutoCompleteArray]
