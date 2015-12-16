//
//  GooglePlacesSearchServiceSpec.swift
//  Places
//
//  Created by Jabari Bell on 12/15/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RxSwift

@testable import Places //forgot to add this initially, go back and clear out all of the publics

class GooglePlacesSearchServiceSpec: QuickSpec {
    override func spec() {
        
        //test fringe cases - error, etc
        describe("a single place search service") {
            
            it("should return an observable of the expected model type") {
//                GooglePlaceSearchable
//                class FakeGooglePlaceSearchable: GooglePlaceSearchable {
//                    typealias T = FormattedGooglePlace
//                    
//                    private func getPlace(placeID: String) -> Observable<FakeGooglePlaceSearchable.T> {
//                        
//                    }
//                }
            }
            
        }
        
        describe("a multiple place search service") {
            
        }
        
        describe("a search service mediator") {
            
        }
        
    }
}
