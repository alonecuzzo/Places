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


//init with a place
class CustomPlaceViewController: UIViewController, UITableViewDelegate, Exitable {
    
    //MARK: Property
    private let tableView = UITableView ()
    private let datasource = RxTableViewSectionedReloadDataSource<SectionModel<String, CustomPlaceTableViewCellType>>()
    private let cells: Variable<[CustomPlaceTableViewCellType]> = Variable([.PlaceName, .StreetAddress, .City, .State, .ZipCode])
    private let disposeBag = DisposeBag()
    var exitingEvent: Variable<ExitingEvent?> = Variable(nil)
    let customPlace = Variable(_Place())//caution might be changed under us, swap out
    
    
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
        
        let cellFactory = CustomPlaceCellFactory.sharedFactory
        datasource.cellFactory = { [unowned self] (tv, _, cellType: CustomPlaceTableViewCellType) in
            return cellFactory.cellForRowWithCellType(cellType, inTableView: tv, bindTo: self.customPlace)
        }
        
        let sectionModels = Variable([SectionModel(model: "Custom Place", items: cells.value)])
        sectionModels.asObservable().bindTo(tableView.rx_itemsWithDataSource(datasource)).addDisposableTo(disposeBag)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        CustomPlaceTableViewCellType.PlaceName.cellForCellTypeInTableView(tableView, withData: cells.value)?.textField.becomeFirstResponder()
    }
    
    private func controlPropertyForCellWithType(cellType: CustomPlaceTableViewCellType) -> ControlProperty<String>? {
        return cellType.cellForCellTypeInTableView(tableView, withData:cells.value)?.textField.rx_text
    }
    
    //MARK: TableViewDelegate
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return PlacesViewStyleCatalog.CustomPlaceTableViewHeaderHeight
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let t = CustomTableHeaderView(frame: CGRectZero)
        t.backbutton.rx_tap.subscribeNext { [unowned self] in
                self.navigationController?.popToRootViewControllerAnimated(true) //should be in presenter
                tableView.endEditing(true)
            }.addDisposableTo(disposeBag)
        return t
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let saveButton = CustomPlaceSaveButton(frame: CGRectZero)
        let exitingCustomPlace = customPlace,
                         event = exitingEvent
        saveButton.button.rx_tap.subscribeNext {
           event.value = ExitingEvent.CustomPlace(exitingCustomPlace.value.asExternalPlace())
        }.addDisposableTo(disposeBag)
        return saveButton
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return PlacesViewStyleCatalog.CustomPlaceTableViewFooterHeight
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
