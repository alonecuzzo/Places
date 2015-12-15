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
typealias OnDoneTappedBlock = () -> ()
typealias OnNextTappedBlock = (CustomPlaceTableViewCellType) -> ()

class CustomPlaceCellFactory: NSObject {
    
    //MARK: Property
    private let customPlaceDisposeBag = CompositeDisposable()
    private var disposeKeys = [CustomPlaceTableViewCellType: DisposeKey]()
    private let onNextBlock: OnNextTappedBlock
    private let onDoneBlock: OnDoneTappedBlock
    
    
    //MARK: Method
    init(onNext: OnNextTappedBlock, onDone: OnDoneTappedBlock) {
        self.onNextBlock = onNext
        self.onDoneBlock = onDone
    }
    
    func cellForRowWithCellType(cellType: CustomPlaceTableViewCellType, inTableView tableView: UITableView, bindTo customPlace: _Place) -> CustomLocationTableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CustomPlaceTableViewCellType.CellIdentifer) as! CustomLocationTableViewCell
        if let disposeKey = disposeKeys[cellType] {
            self.customPlaceDisposeBag.removeDisposable(disposeKey)
        }
        cell.textField.cellType = cellType
        
        let disposable: Disposable
        switch cellType {
        case .PlaceName:
            disposable = cell.textField.rx_text <-> customPlace.name
        case .StreetAddress:
            disposable = cell.textField.rx_text <-> customPlace.streetAddress
        case .City:
            disposable = cell.textField.rx_text <-> customPlace.cityTown
        case .State:
            disposable = cell.textField.rx_text <-> customPlace.state
        case .ZipCode:
            disposable = cell.textField.rx_text <-> customPlace.zipCode
        }
        let key = customPlaceDisposeBag.addDisposable(disposable)
        disposeKeys[cellType] = key
        cell.textField.placeholder = cellType.placeHolder
        cell.textField.returnKeyType = cellType.returnKeyType
        cell.textField.delegate = self
        return cell
    }
}

extension CustomPlaceCellFactory: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        guard let tf = textField as? CustomLocationTableViewCellTextField else { return false }
        guard let cellType = tf.cellType else { return false }
        switch cellType.returnKeyType {
        case .Done:
            onDoneBlock()
        case .Next:
            onNextBlock(cellType)
        default:
            return false
        }
        return true
    }
}
