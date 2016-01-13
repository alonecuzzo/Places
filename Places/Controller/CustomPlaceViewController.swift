//
//  CustomLocationViewController.swift
//  Places
//
//  Created by Sarah Griffis on 11/3/15.
//  Copyright © 2015 Paperless Post. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources


class CustomPlaceViewController: UIViewController, Exitable {
    
    //MARK: Property
    var exitingEvent: Variable<ExitingEvent?> = Variable(nil)
    var customPlace = _EventPlace()
    
    private let tableView = UITableView ()
    private let datasource = RxTableViewSectionedReloadDataSource<SectionModel<String, CustomPlaceTableViewCellType>>()
    private let cells: [CustomPlaceTableViewCellType] = [.PlaceName, .StreetAddress, .City, .State, .ZipCode]
    private let disposeBag = DisposeBag()
    private let presenter = PlacesAutoCompletePresenter()
    
    
    //MARK: Method
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() -> Void {
        view.addSubview(tableView)
        
        let cellIdentifier = CustomPlaceTableViewCellType.State.cellIdentifier
        tableView.registerClass(CustomLocationTableViewCell.classForCoder(), forCellReuseIdentifier: cellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.scrollEnabled = false
        tableView.delegate = self
        tableView.rowHeight = PlacesViewStyleCatalog.CustomPlaceTableViewRowHeight
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.layoutMargins = UIEdgeInsetsZero  
        
        tableView.snp_makeConstraints { (make) -> Void in
            make.top.bottom.right.left.equalTo(self.view)
        }
        
        let cellFactory = CustomPlaceCellFactory(
            onNext: { [unowned self] (cellType) -> () in
                guard let nextTextField = self.textFieldForCellFollowingCellWithCellType(cellType) else { return }
                dispatch_async(dispatch_get_main_queue()) {
                    nextTextField.becomeFirstResponder()
                }
            },
            onDone: { [unowned self] in
                self.exitingEvent.value = ExitingEvent.CustomPlace(self.customPlace.eventPlace)
        })
        
        datasource.cellFactory = { [unowned self] (tv, _, cellType: CustomPlaceTableViewCellType) in
            let returnKeyType = (cellType == self.cells.last) ? UIReturnKeyType.Done : .Next
            return cellFactory.cellForRowWithCellType(cellType, inTableView: tv, bindTo: self.customPlace, returnKeyType: returnKeyType)
        }
        
        let sectionModels = Variable([SectionModel(model: "Custom Place", items: cells)])
        sectionModels.asObservable().bindTo(tableView.rx_itemsWithDataSource(datasource)).addDisposableTo(disposeBag)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        CustomPlaceTableViewCellType.PlaceName.cellForCellTypeInTableView(tableView, withData: cells)?.textField.becomeFirstResponder()
    }
    
    override func prefersStatusBarHidden() -> Bool { return true }
}


//MARK: TableViewDelegate
extension CustomPlaceViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return PlacesViewStyleCatalog.CustomPlaceTableViewHeaderHeight
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let t = EventDetailsLocationPickerCustomTableHeaderView(frame: CGRectZero)
        t.backbutton.rx_tap.subscribeNext { [unowned self] in
                self.presenter.dismissViewController(self)
                tableView.endEditing(true)
            }.addDisposableTo(disposeBag)
        return t
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let saveButton = CustomPlaceSaveButton(frame: CGRectZero)
        let exitingCustomPlace = customPlace,
                         event = exitingEvent
        saveButton.button.rx_tap.subscribeNext {
           event.value = ExitingEvent.CustomPlace(exitingCustomPlace.eventPlace)
        }.addDisposableTo(disposeBag)
        return saveButton
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return PlacesViewStyleCatalog.CustomPlaceTableViewFooterHeight
    }
}

// MARK: - Helper
extension CustomPlaceViewController {
    private func controlPropertyForCellWithType(cellType: CustomPlaceTableViewCellType) -> ControlProperty<String>? {
        return cellType.cellForCellTypeInTableView(tableView, withData:cells)?.textField.rx_text
    }
    
    private func textFieldForCellFollowingCellWithCellType(cellType: CustomPlaceTableViewCellType) -> UITextField? {
        guard let index = self.cells.indexOf(cellType) else { return nil }
        let nextIndex = index + 1
        if nextIndex > self.cells.count - 1 { return nil }
        let newType = self.cells[nextIndex]
        return newType.cellForCellTypeInTableView(self.tableView, withData: self.cells)?.textField
    }
}
