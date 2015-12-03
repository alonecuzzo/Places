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

enum CustomPlaceTableViewCellType {
    case PlaceName, StreetAddress, City, State, ZipCode
    
    var placeHolder: String {
        switch self {
        case .PlaceName:
            return "Venue Name"
        case .StreetAddress:
            return "Address"
        case .City:
            return "City/Town"
        case .State:
            return "State"
        case .ZipCode:
            return "Zip/ Postal Code"
        }
    }
    
    var disposeKey: DisposeKey
    static let CellIdentifer = "CustomPlaceTableViewCellTypeCellIdentifier"
}

//need to find custom cell, then bind it
extension CustomPlaceTableViewCellType {
   //maybe cell for row with datasource?
    //or i can get model at index
    func cellForCellTypeInTableView(tableView: UITableView, withData data: [CustomPlaceTableViewCellType]) -> CustomLocationTableViewCell? {
        guard let index = data.indexOf(self) else { return nil }
        return tableView.cellForRowAtIndexPath(NSIndexPath(forItem: index, inSection: 0)) as? CustomLocationTableViewCell
    }
}


//init with a place
class CustomPlaceViewController: UIViewController, UITableViewDelegate, Exitable {
    
    //MARK: Property
    private let tableView = UITableView ()
    private let datasource = RxTableViewSectionedReloadDataSource<SectionModel<String, CustomPlaceTableViewCellType>>()
    private let cells: Variable<[CustomPlaceTableViewCellType]> = Variable([.PlaceName, .StreetAddress, .City, .State, .ZipCode])
    private let disposeBag = DisposeBag()
    var exitingEvent: Variable<ExitingEvent?> = Variable(nil)
    private let customPlace = Variable(Place())//caution might be changed under us, swap out
    
    private let customPlaceDisposeBag = CompositeDisposable()
    
    
    //MARK: Method
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() -> Void {
        setupTableView()
    }
    
    private func setupTableView() -> Void {
        view.addSubview(tableView)
        tableView.registerClass(CustomLocationTableViewCell.classForCoder(), forCellReuseIdentifier: CustomPlaceTableViewCellType.CellIdentifer)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.scrollEnabled = false
        tableView.delegate = self
        
        tableView.snp_makeConstraints { (make) -> Void in
            make.top.bottom.right.left.equalTo(self.view)
        }
        
        datasource.cellFactory = { [weak self] (tv, ip, cellType: CustomPlaceTableViewCellType) in
            let cell = tv.dequeueReusableCellWithIdentifier(CustomPlaceTableViewCellType.CellIdentifer) as! CustomLocationTableViewCell
            //set the binding here
            //maybe a block for when the cell is dequeued
            self?.customPlaceDisposeBag.removeDisposable(type.key)
            let disposable = cell.textField.rx_text <-> (self?.customPlace.value.name)!
            let key = self?.customPlaceDisposeBag.addDisposable(disposable)
            
            cell.textField.placeholder = cellType.placeHolder
            return cell
        }
        
        let sectionModels = Variable([SectionModel(model: "Custom Place", items: cells.value)])
        sectionModels.asObservable().bindTo(tableView.rx_itemsWithDataSource(datasource)).addDisposableTo(disposeBag)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        CustomPlaceTableViewCellType.PlaceName.cellForCellTypeInTableView(tableView, withData: cells.value)?.textField.becomeFirstResponder()
        setCustomPlaceBindings()//seems silly to put this here, we want the bindings to be fresh in the cell factory
        //then how do we dispose of old ones, use a composite dispose bag
        //we need a dispose bag, and we also need to keep a set of dispose keys that are associated with the type... the dispose key gets set when something is added...
    }
    
    private func setCustomPlaceBindings() -> Void {
        for cellType in cells.value {
            
            guard let controlProperty = controlPropertyForCellWithType(cellType) else { return }
            
//         if/let   
            
            switch cellType {
            case .PlaceName:
                controlProperty <-> customPlace.value.name
            case .StreetAddress:
                controlProperty <-> customPlace.value.streetAddress
            case .City:
                controlProperty <-> customPlace.value.cityTown
            case .State:
                controlProperty <-> customPlace.value.state
            case .ZipCode:
                controlProperty <-> customPlace.value.zipCode
            }
        }
    }
    
    private func controlPropertyForCellWithType(cellType: CustomPlaceTableViewCellType) -> ControlProperty<String>? {
        return cellType.cellForCellTypeInTableView(tableView, withData:cells.value)?.textField.rx_text
    }
    
    //MARK: TableViewDelegate
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return PlacesViewStyleCatalog.CustomPlaceTableViewFooterHeight
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let t = customTableHeaderView(frame: CGRectZero)
        t.backbutton.rx_tap.subscribeNext { [unowned self] in
                self.navigationController?.popToRootViewControllerAnimated(true) //should be in presenter
                tableView.endEditing(true)
            }.addDisposableTo(disposeBag)
        return t
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let saveButton = CustomPlaceSaveButton(frame: CGRectZero)
        let event = exitingEvent
        let exitingCustomPlace = customPlace
        saveButton.button.rx_tap.subscribeNext {
           event.value = ExitingEvent.CustomPlace(exitingCustomPlace.value)
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


class CustomPlaceSaveButton: UIView {
    
    //MARK: Property
    let button = UIButton(frame: CGRectZero)

    
    //MARK: Method
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() -> Void {
        button.setTitle("SAVE", forState: .Normal)
        button.backgroundColor = UIColor.blackColor()
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = UIFont (name: "HelveticaNeue-Medium", size: 12)
        self.addSubview(button)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.frame = CGRect(x: self.frame.width / 2 - 160 / 2, y: self.frame.height / 2 - 44 / 2, width: 160, height: 44)
    }
}

class customTableHeaderView: UIView {
    
    let label = UILabel(frame: CGRectZero)
    let backbutton = UIButton(frame: CGRectZero)
 

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        label.text =  "Add custom location"
        label.textAlignment = .Center
        backbutton.setImage(UIImage(named: "icon-backArrow-black"), forState: UIControlState.Normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        label.frame = self.frame
        backbutton.frame = CGRect(x: 16, y: 0, width: 20, height: self.frame.height)
        
        self.addSubview(label)
        self.addSubview(backbutton)
        
        
        let border = CALayer()
        let width = CGFloat(0.8)
        
        //default gray color on UITableViewSeparator
        border.borderColor = UIColor(red: 0.783922, green: 0.780392, blue: 0.8, alpha: 1.0).CGColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}


class CustomLocationTableViewCell: UITableViewCell {
    
    var textField = UITextField(frame: CGRectZero)
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        //contentView.addSubview(textfield)
        textField.font = UIFont (name: "HelveticaNeue", size: 16)
        self.selectionStyle = .None
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setup() {
        [textField].forEach { self.addSubview($0) }
    }
    
    override func didMoveToSuperview() {
        
        textField.snp_makeConstraints { make in
            self.setTextFieldConstraints(make)
        }
        
    }
    
    func setTextFieldConstraints(make: ConstraintMaker) {
        
        make.left
            .equalTo(self)
            .inset(16)
        
        make.centerY
            .equalTo(self)
        
    }
}