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
        presentViewControllerForItem(item, fromViewController: viewController, customPlace: nil)
    }
    
    func presentViewControllerForItem(item: GooglePlacesDatasourceItem, fromViewController viewController: PlacesAutoCompleteViewController, customPlace: _Place?) -> Void {
        
        guard let navigationController = viewController.navigationController else { return }
        
        switch item {
            
        case let .PlaceCell(place):
            let presenter = PlacesAutoCompletePresenter.sharedPresenter
            presenter.exitingEventForPlacesAutoCompleteViewController(viewController, withPlace: place).subscribeNext { event -> Void in
                viewController.exitingEvent.value = event
            }.addDisposableTo(presenter.disposeBag)
            
        case .CustomPlaceCell:
            viewController.view.endEditing(true)
            let cspvc = CustomPlaceViewController()
            cspvc.exitingEvent = viewController.exitingEvent
            if let customPlace = customPlace { cspvc.customPlace = customPlace }
            navigationController.pushViewController(cspvc, animated: true)
        }
    }
    
    func exitingEventForPlacesAutoCompleteViewController(viewController: PlacesAutoCompleteViewController, withPlace place: _Place) -> Observable<ExitingEvent> {
        let disposeBag = self.disposeBag
        return Observable.create { observer in
            viewController.viewModel.getPlace(place).subscribeNext { place in
                observer.onNext(.AutoCompletePlace(place.asExternalPlace()))
            }.addDisposableTo(disposeBag)
            return NopDisposable.instance
        }
    }
    
    func dismissViewController(viewController: UIViewController) -> Void {
        viewController.navigationController?.popToRootViewControllerAnimated(true)
    }
}


//MARK: Helper
extension PlacesAutoCompletePresenter {
    func presentCustomPlaceViewControllerFromViewController(viewController: PlacesAutoCompleteViewController, withCustomPlace customPlace: _Place) -> Void {
        presentViewControllerForItem(.CustomPlaceCell, fromViewController: viewController, customPlace: customPlace)
    }
}
