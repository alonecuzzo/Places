//
//  CustomLocationViewController.swift
//  Places
//
//  Created by Sarah Griffis on 11/3/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa


class CustomPlaceViewController: UIViewController, Exitable {
    
    //MARK: Property
    private let tableView = UITableView ()
    private let datasource = RxTableViewSectionedReloadDataSource<SectionModel<String, CustomPlaceTableViewCellType>>()
    private let cells: [CustomPlaceTableViewCellType] = [.PlaceName, .StreetAddress, .City, .State, .ZipCode] //look to see if the last cell .Done
    private let disposeBag = DisposeBag()
    var exitingEvent: Variable<ExitingEvent?> = Variable(nil)
    var customPlace = _Place()
    
    
    //MARK: Method
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() -> Void {
        view.addSubview(tableView)
        tableView.registerClass(CustomLocationTableViewCell.classForCoder(), forCellReuseIdentifier: CustomPlaceTableViewCellType.CellIdentifer)
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
                nextTextField.becomeFirstResponder()
            },
            onDone: { [unowned self] in
                self.exitingEvent.value = ExitingEvent.CustomPlace(self.customPlace.asExternalPlace())
        })
        
        datasource.cellFactory = { [unowned self] (tv, _, cellType: CustomPlaceTableViewCellType) in
            return cellFactory.cellForRowWithCellType(cellType, inTableView: tv, bindTo: self.customPlace)
        }
        
        let sectionModels = Variable([SectionModel(model: "Custom Place", items: cells)])
        sectionModels.asObservable().bindTo(tableView.rx_itemsWithDataSource(datasource)).addDisposableTo(disposeBag)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        CustomPlaceTableViewCellType.PlaceName.cellForCellTypeInTableView(tableView, withData: cells)?.textField.becomeFirstResponder()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}


//MARK: TableViewDelegate
extension CustomPlaceViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return PlacesViewStyleCatalog.CustomPlaceTableViewHeaderHeight
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let t = CustomTableHeaderView(frame: CGRectZero)
        t.backbutton.rx_tap.subscribeNext { [unowned self] in
                PlacesAutoCompletePresenter.sharedPresenter.dismissViewController(self)
                tableView.endEditing(true)
            }.addDisposableTo(disposeBag)
        return t
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let saveButton = CustomPlaceSaveButton(frame: CGRectZero)
        let exitingCustomPlace = customPlace,
                         event = exitingEvent
        saveButton.button.rx_tap.subscribeNext {
           event.value = ExitingEvent.CustomPlace(exitingCustomPlace.asExternalPlace())
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
