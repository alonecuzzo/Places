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

let paperlessPostLocation = Variable(CLLocation(latitude: 40.708882, longitude: -74.0136213))

class GooglePlacesSearchViewModelSpec: QuickSpec {
    
    
    override func spec() {
        let disposeBag = DisposeBag()
        
        describe("user typing into auto complete search field") {
            
            it("should search using the expected query") {
                let queryString = "LolCatz"
                let query = Variable(queryString).asDriver(onErrorJustReturn: "")
                let spyService = FakeGoogleSearchService()
                
                query.asObservable().subscribeNext { _ in }.addDisposableTo(disposeBag) //make signal hot
                
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
        }
        
        describe("user selecting place from the autocomplete table") {
            
            it("should return the expected place") {
                let placeID = "3982y03h29-23983-1111"
                let spyService = FakeGoogleSearchService()
                let vm = GooglePlacesSearchViewModel(searchText: Variable("").asDriver(onErrorJustReturn: ""), currentLocation: paperlessPostLocation, service: spyService)
                vm.getPlace(placeID).subscribe { event -> Void in
                    switch event {
                    case .Next(_):
                        guard let capturedRequest = spyService.placeRequests.first else { fail(); break }
                        expect(capturedRequest.placeID).to(equal(placeID))
                    case .Error:
                        fail("failed with placeID: \(placeID)")
                    default:
                        break
                    }
                }.addDisposableTo(disposeBag)
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
        return just([AutoCompleteGooglePrediction(placeID: "", attributedText: NSAttributedString(string: ""))])
    }
    
    override func getPlace(placeID: String) -> Observable<FormattedGooglePlace> {
        placeRequests.append(FakePlaceSearchRequest(placeID: placeID))
        return just(FormattedGooglePlace(placeID: placeID, formattedAddress: ""))
    }
}

struct FakePlaceSearchRequest {
    let placeID: String
}

struct FakeAutoCompleteSearchRequest {
    let query: String
    let location: CLLocation
}
