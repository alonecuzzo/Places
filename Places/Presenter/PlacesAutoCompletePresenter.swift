//
//  PlacesAutoCompletePresenter.swift
//  Places
//
//  Created by Jabari Bell on 11/29/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import UIKit
import RxSwift


class PlacesAutoCompletePresenter {
    
    //MARK: Property
    static let sharedPresenter = PlacesAutoCompletePresenter()
    let disposeBag = DisposeBag()
    
    
    //MARK: Method
    private init() {}
    
    func presentViewControllerForItem(item: GooglePlacesDatasourceItem, fromViewController viewController: PlacesAutoCompleteViewController) -> Void {
        
        guard let navigationController = viewController.navigationController else { return }
        
        //this should really be buried in a router - it can just pick a route based on the item type
        switch item {
        case let .PlaceCell(place): //BIND THIS TO THE FUNCTION exitingEventForPlacesAutoCompleteViewController
            let presenter = PlacesAutoCompletePresenter.sharedPresenter
            presenter.exitingEventForPlacesAutoCompleteViewController(viewController, withPlace: place).subscribeNext { event -> Void in
                viewController.exitingEvent.value = event
            }.addDisposableTo(presenter.disposeBag)
        case .CustomPlaceCell:
            //we need the exiting event to be passed along
            viewController.view.endEditing(true)
            let cspvc = CustomPlaceViewController()
            cspvc.exitingEvent = viewController.exitingEvent
            navigationController.pushViewController(cspvc, animated: true)
        }
    }
    
    func exitingEventForPlacesAutoCompleteViewController(viewController: PlacesAutoCompleteViewController, withPlace place: _Place) -> Observable<ExitingEvent> {
        let disposeBag = self.disposeBag
        return create { observer in
            viewController.viewModel.getPlace(place.placeID.value).subscribeNext { place in
                observer.onNext(.AutoCompletePlace(place.asPlace()))
            }.addDisposableTo(disposeBag)
            return NopDisposable.instance
        }
    }
}
