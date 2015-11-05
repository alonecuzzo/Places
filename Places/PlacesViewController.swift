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

class PlacesViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: Property
    private let tableView = UITableView()
    private let searchBar = LocationSearchView()
    private var places = [GMSAutocompletePrediction]()
    private let CellIdentifier = "CellIdentifier"
    private var placesClient: GMSPlacesClient?
    
    //Testing @40.708882,-74.0136213
    private let paperlessPostLocation = CLLocation(latitude: 40.708882, longitude: -74.0136213)

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    //MARK: Method
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.setup()
    }
    
    private func setup() -> Void {
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: CellIdentifier)
        

        [tableView, searchBar].forEach { self.view.addSubview($0) }
        
        searchBar.snp_makeConstraints { (make) -> Void in
            
            make.left
                .right
                .equalTo(self.view)
                .priorityHigh()
            
            make.top
                .equalTo(self.view.snp_top)
                .offset(topLayoutGuide.length)
                .priorityHigh()
            
            make.height
                .greaterThanOrEqualTo(55)
        }
        
        tableView.snp_makeConstraints { (make) -> Void in
            

            make.left
                .right
                .bottom
                .equalTo(self.view)
                .priorityHigh()
            
            make.top.equalTo(searchBar.snp_bottom)
        }
    
        //places stuff -> viewmodel / services
        
        placesClient = GMSPlacesClient()
    }
    
    //MARK: TableViewDatasource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = places.count + 1
        return rows
    }
    
    //MARK: TableViewDelegate
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: tableView.frame.width, height: 55)))
        let label = UILabel(frame: view.frame)
        //let height = tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forItem: 1, inSection: 1))
        label.text = "Add custom location"
        
        return view
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //select the last row
        //print("\(indexPath.row)")
        if indexPath.row == places.count {
            print("selected last at \(indexPath.row)")
            let vc = CustomLocationViewController()
            self.presentViewController(vc, animated: true, completion: nil)
        } else {
            print("\(indexPath.row)")
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier)
        
        if (cell != nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: CellIdentifier)
        }
        
        //last cell is the 'Add custom location' cell, so we do not have places data for it
        if (places.count > 0 && indexPath.row != places.count)  {
            let string = places[indexPath.row].attributedFullText.string
            
            let firstLineIndices = string.rangeOfString("^[^,]*", options: .RegularExpressionSearch)
            //let secondLineIndices = string.rangeOfString(",(.*)", options: .RegularExpressionSearch)
            
            let charSet = NSCharacterSet(charactersInString: ",")
            
            var array = string.componentsSeparatedByCharactersInSet(charSet)

            let arr = array[1..<array.count].joinWithSeparator(", ")
        //        
        //        //let regex = NSRegularExpression(pattern: ",(.*)", options: NSRegularExpressionOptions.CaseInsensitive)
        //        var error: NSError? = nil
        //
            //var regex = NSRegularExpression(pattern: ",(.*)", options: NSRegularExpressionOptions.DotMatchesLineSeparators)

        
//        do {
//                let regex = try NSRegularExpression(pattern: ",(.*)", options: NSRegularExpressionOptions.CaseInsensitive)
//                let matches = regex.matchesInString(string, options: [], range: NSMakeRange(0, string.characters.count))
//                let firstMatch = regex.firstMatchInString(string, options: [], range: NSMakeRange(0, string.characters.count))
//                let range = matches.first?.range
//            //range.
//             var temp = string as NSString
//            
//
//                //print(string.substringWithRange(NSRange(location: range!.location, length: range!.length)))
//            //string.substringWithRange(Range<String.Index>(start: range?.location, end:  range?.length))
//            print(temp.substringWithRange(NSRange(location: range!.location, length: range!.length)))
//
//        }
//        catch{}
        
        //if tableView.
        
            cell!.textLabel?.numberOfLines = 0
            cell!.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell!.textLabel?.text = string[firstLineIndices!]
            cell!.detailTextLabel?.text = arr
        //places[indexPath.row].attributedFullText
        } else {
            cell!.textLabel?.text = "Add custom location"
        
        }
        
        return cell!
    }
    
    //MARK: SearchBarDelegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) -> Void {
        
        let northEast = CLLocationCoordinate2DMake(paperlessPostLocation.coordinate.latitude + 1, paperlessPostLocation.coordinate.longitude + 1)
        let southWest = CLLocationCoordinate2DMake(paperlessPostLocation.coordinate.latitude - 1, paperlessPostLocation.coordinate.longitude - 1)
        let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.NoFilter
        if searchText.characters.count > 0 {
            //print("Searching for '\(searchText)'")
            placesClient?.autocompleteQuery(searchText, bounds: bounds, filter: filter, callback: { (results, error) -> Void in
                
                if error != nil {
                    print("Autocomplete error \(error) for query '\(searchText)'")
                    return
                }
                
                //print("Populating results for query '\(searchText)'")
                self.places = [GMSAutocompletePrediction]()
                for result in results! {
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
    }
}

class CellIdentifier: UITableViewCell {
}


class LocationSearchView: UIView {
  
    let textfield: UITextField = {
        var textField = UITextField()
        textField.placeholder = "Type to search for location"
        return textField
    }()
    
    
    let searchIcon: UIButton = {
        let searchIcon = UIButton.init(type: UIButtonType.Custom)
        //searchIcon.backgroundColor = UIColor.redColor()
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
        border.borderColor = UIColor(red: 0.783922, green: 0.780392, blue: 0.8, alpha: 1.0).CGColor
        border.frame = CGRect(x: 5, y: self.frame.size.height - width, width:  self.frame.size.width - 10, height: self.frame.size.height)
        
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
            .inset(5)
        
        make.right.equalTo(searchIcon.snp_left).inset(5)
    }
    
    func setSearchIconConstraints(make: ConstraintMaker) {
        
        make.top
            .right
            .bottom
            .equalTo(self)
            .inset(5)
    }
}

