//
//  ViewController.swift
//  Places
//
//  Created by Jabari Bell on 11/2/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import SnapKit

struct PlacesViewModel {
    //list of places -> just bind to this
    //maybe we convert to our own place model object
    var places = [GMSAutocompletePrediction]() //Model should be hidden
    
    //binding for search
    //internally updates places array
    func placesForLocation(location: CLLocation, searchString string: String) {
        
    }
    
    //configureCellForRowAtindexPath
    
}


private enum PlacesCellType {
    case PlacesResultType
    //We store the index of the actual item on the enum to avoid having to do any maths later on
    case AddCustomLocationType

    
    static func allCellTypes() -> [PlacesCellType] {
        return [PlacesCellType.PlacesResultType, PlacesCellType.AddCustomLocationType]
    }
    
    var cellIdentifier: String {
        switch self {
        case .PlacesResultType:
            return "places result"
        case .AddCustomLocationType:
            return "add custom location"
        }
    }
    
    var cellClass: AnyClass {
        switch self {
        case .PlacesResultType:
            return UITableViewCell.classForCoder()
        case .AddCustomLocationType:
            return AddCustomLocationCell.classForCoder()
        }
    }
    
}

private struct StyleParameters {

    
}

class PlacesViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    //MARK: Property
    private let tableView: UITableView = {
        
        let t = UITableView(frame: CGRectZero, style: UITableViewStyle.Plain)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.rowHeight = UITableViewAutomaticDimension
        t.estimatedRowHeight = 55
//        t.tableFooterView = UIView(frame: CGRectZero)
//        t.tableFooterView?.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    private let searchBar: LocationSearchView = {
        
        let s = LocationSearchView(frame: CGRectZero)
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    private let googleImageView: UIImageView = {
    
        let googleImageView = UIImageView(image: UIImage(named: "poweredByGoogle"))
        googleImageView.layer.borderColor = UIColor.redColor().CGColor
        googleImageView.layer.borderWidth = 2
        googleImageView.translatesAutoresizingMaskIntoConstraints = false
        return googleImageView
    }()
    
    private var places = [GMSAutocompletePrediction]()
    private var placesClient: GMSPlacesClient?

    
    //Testing @40.708882,-74.0136213
    private let paperlessPostLocation = CLLocation(latitude: 40.708882, longitude: -74.0136213)

    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    //MARK: Method
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //self.setup()
    }
    
    private func setup() -> Void {
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView?.backgroundColor = UIColor.greenColor()
        tableView.tableFooterView = UIView(frame: CGRectZero)
        


        for cellType in PlacesCellType.allCellTypes() {
            tableView.registerClass(cellType.cellClass, forCellReuseIdentifier: cellType.cellIdentifier)
        }
        
        searchBar.textfield.delegate = self
        searchBar.searchIcon.addTarget(self, action: "pressedXButton:", forControlEvents: .TouchUpInside)

        [tableView, searchBar].forEach { self.view.addSubview($0) }
        
        searchBar.snp_makeConstraints { (make) -> Void in
            
            make.left
                .right
                .equalTo(tableView)
                .priority(1000)

            make.top
                .equalTo(self.view.snp_top)
                .priority(1000)

            make.height
                .equalTo(55)
                .priority(750)

        }
        
        tableView.snp_makeConstraints { (make) -> Void in
            
//            make.left.equalTo(self.view).priority(1000)
//            make.right.equalTo(self.view).priority(1000)
//            make.top.equalTo(searchBar.snp_bottom).priority(1000)
//            make.bottom.equalTo(self.view).priority(750)
            
            make.left
                .right
                .equalTo(self.view)
                .priority(1000)
            
            make.bottom
                .equalTo(self.view)
                .priority(750)
            
            make.top.equalTo(searchBar.snp_bottom)
        }
        
        //allocated in class declaration
//        [googleImageView].forEach { self.tableView.tableFooterView!.addSubview($0) }
//        
//        
        self.tableView.tableFooterView!.snp_makeConstraints { (make) -> Void in
            
            make.right
                .left
                .bottom
                .equalTo(tableView)

            make.height
                .equalTo(50)
                .priorityHigh()
            
//            make.left.equalTo(self.tableView).priority(1000)
//            make.right.equalTo(self.tableView).priority(1000)
//            
//            make.height.equalTo(200).priority(750)
//            make.width.equalTo(tableView).priority(750)
            make.centerY.equalTo(tableView)
        }
        
        
//        googleImageView.snp_makeConstraints { (make) -> Void in
//            
//            make.centerY
//                .equalTo(tableView.tableFooterView!)
//                .priority(1000)
//            
//            make.left
//                .equalTo(tableView)
//            
//        }
    
        //places stuff -> viewmodel / services
        
        placesClient = GMSPlacesClient()
    }
    
    //MARK: TableViewDatasource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = places.count + 1
        return rows
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if indexPath.row == places.count {
            let vc = CustomLocationViewController()
            self.presentViewController(vc, animated: true, completion: nil)
        } else {
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        //last cell is the 'Add custom location' cell, so we do not have places data for it
        let cellType = (places.count > 0 && indexPath.row != places.count) ? PlacesCellType.PlacesResultType : PlacesCellType.AddCustomLocationType

        
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellType.cellIdentifier) as UITableViewCell!
        
        switch cellType {
        
        case .PlacesResultType:
            
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellType.cellIdentifier)

            let string = places[indexPath.row].attributedFullText.string
            
            //let firstLineIndices = string.rangeOfString("^[^,]*", options: .RegularExpressionSearch)
            
            //Separated the string by commas
            let charSet = NSCharacterSet(charactersInString: ",")
            let arrayOfStrings = string.componentsSeparatedByCharactersInSet(charSet)
            
            let titleString = arrayOfStrings[0]
            
            let detailString = arrayOfStrings[1..<arrayOfStrings.count].joinWithSeparator(", ")
            //remove leading white space
            let detailStringChomped = detailString[detailString.startIndex.advancedBy(1)..<detailString.startIndex.advancedBy(detailString.characters.count)]

            cell.textLabel?.font = UIFont (name: "HelveticaNeue", size: 16)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell.textLabel?.text = titleString
            cell.detailTextLabel?.font = UIFont (name: "HelveticaNeue", size: 14)
            cell.detailTextLabel?.text = detailStringChomped
            
        case .AddCustomLocationType:
            cell.tintColor = UIColor.blackColor()
        }

        return cell
    }
    
    
    //MARK: textfieldDelegate
    func textFieldDidBeginEditing(textField: UITextField) {
        
        searchBar.searchIcon.enabled = true
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        searchBar.searchIcon.enabled = true
        
        let northEast = CLLocationCoordinate2DMake(paperlessPostLocation.coordinate.latitude + 1, paperlessPostLocation.coordinate.longitude + 1)
        let southWest = CLLocationCoordinate2DMake(paperlessPostLocation.coordinate.latitude - 1, paperlessPostLocation.coordinate.longitude - 1)
        let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.NoFilter
        
        if textField.text!.characters.count > 0 {
            //print("Searching for '\(searchText)'")
            placesClient?.autocompleteQuery(textField.text!, bounds: bounds, filter: filter, callback: { (results, error) -> Void in
                
                if error != nil {
                    print("Autocomplete error \(error) for query '\(textField.text!)'")
                    return
                }
                
                //print("Populating results for query '\(searchText)'")
                self.places = [GMSAutocompletePrediction]()
                for result in results![0..<min(results!.count, 3) ] {
                    if let result = result as? GMSAutocompletePrediction {
                        self.places.append(result)
                    }
                }
                self.tableView.reloadData()
            })
        } else {
            self.places = [GMSAutocompletePrediction]()
            self.tableView.reloadData()
        }
        
        return true
    }
    
    //MARK: PressedXButton
    func pressedXButton(sender: UIButton!){

        searchBar.textfield.text = ""
        searchBar.searchIcon.enabled = false
    }
    

//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//      
//        if touches.first?.view != searchBar.textfield {
//            searchBar.textfield.resignFirstResponder()
//        }
//        
//    }
}

class AddCustomLocationCell: UITableViewCell {
    
    let cellText = "Add custom location"
    let pencilImageView = UIImageView(image: UIImage(named: "icon-pencil"))
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.textLabel!.text = cellText
        self.textLabel?.font = UIFont (name: "HelveticaNeue", size: 20)
        self.setup()
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        [pencilImageView].forEach { self.addSubview($0) }
        
        pencilImageView.snp_makeConstraints { (make) -> Void in
            
            make.right
                .equalTo(self)
                .inset(16)
            

            make.height
                .equalTo(22)
            
            
            make.centerY
                .equalTo(self)
        }
    }
}


class LocationSearchView: UIView {
  
    let textfield: UITextField = {
        var textField = UITextField()
        textField.placeholder = "Type to search for location"
        textField.font = UIFont(name: "HelveticaNeue", size: 20)
        return textField
    }()
    
    
    let searchIcon: UIButton = {
        let searchIcon = UIButton.init(type: UIButtonType.Custom)
        searchIcon.enabled = false
        searchIcon.setImage(UIImage(named: "icon-search"), forState: UIControlState.Disabled)
        searchIcon.setImage(UIImage(named: "icon-x"), forState: UIControlState.Normal)
        return searchIcon
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let border = CALayer()
        let width = CGFloat(0.8)
        
        //default gray color on UITableViewSeparator
        border.borderColor = UIColor(red: 0.783922, green: 0.780392, blue: 0.8, alpha: 1.0).CGColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    private func setup() {
        [textfield, searchIcon].forEach { self.addSubview($0) }
    }

    override func didMoveToSuperview() {
        
        textfield.snp_makeConstraints { make in
            self.setTextFieldConstraints(make)
        }
        
        searchIcon.snp_makeConstraints { make in
            self.setSearchIconConstraints(make)
        }
    }
    
    func setTextFieldConstraints(make: ConstraintMaker) {
        
        make.top
            .left
            .bottom
            .equalTo(self)
            .inset(16)

        make.right.equalTo(searchIcon.snp_left).inset(16)
    }
    
    func setSearchIconConstraints(make: ConstraintMaker) {
        
        make.top
            .right
            .bottom
            .equalTo(self)
            .inset(16)
        
        make.height
            .greaterThanOrEqualTo(22)
    }
}

