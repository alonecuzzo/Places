//
//  CustomPlaceCellFactory.swift
//  Places
//
//  Created by Jabari Bell on 12/7/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import Foundation
import RxSwift

typealias DisposeKey = Bag<Disposable>.KeyType

class CustomPlaceCellFactory {
    
    //MARK: Property
    static let sharedFactory = CustomPlaceCellFactory()
    private let customPlaceDisposeBag = CompositeDisposable()
    private var disposeKeys = [CustomPlaceTableViewCellType: DisposeKey]()
    
    
    //MARK: Method
    func cellForRowWithCellType(cellType: CustomPlaceTableViewCellType, inTableView tableView: UITableView, bindTo customPlace: Variable<_Place>) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CustomPlaceTableViewCellType.CellIdentifer) as! CustomLocationTableViewCell
        if let disposeKey = disposeKeys[cellType] {
            self.customPlaceDisposeBag.removeDisposable(disposeKey)
        }
        
        let disposable: Disposable
        switch cellType {
        case .PlaceName:
            disposable = cell.textField.rx_text <-> customPlace.value.name
        case .StreetAddress:
            disposable = cell.textField.rx_text <-> customPlace.value.streetAddress
        case .City:
            disposable = cell.textField.rx_text <-> customPlace.value.cityTown
        case .State:
            disposable = cell.textField.rx_text <-> customPlace.value.state
        case .ZipCode:
            disposable = cell.textField.rx_text <-> customPlace.value.zipCode
        }
        let key = customPlaceDisposeBag.addDisposable(disposable)
        disposeKeys[cellType] = key
        cell.textField.placeholder = cellType.placeHolder
        return cell
    }
}
