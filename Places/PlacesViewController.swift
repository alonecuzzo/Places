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

class PlacesViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource {
    
    //MARK: Property
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private var places = [GMSAutocompletePrediction]()
    private let CellIdentifier = "CellIdentifier"
    private var placesClient: GMSPlacesClient?
    
    //Testing @40.708882,-74.0136213
    private let paperlessPostLocation = CLLocation(latitude: 40.708882, longitude: -74.0136213)

    
    //MARK: Method
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() -> Void {
        view.addSubview(tableView)
        tableView.tableHeaderView = searchBar
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: CellIdentifier)
        
        tableView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(view)
        }
        
        searchBar.snp_makeConstraints { (make) -> Void in
            make.left.right.equalTo(view)
            make.top.equalTo(0)
            make.height.equalTo(55)
        }
        
        searchBar.delegate = self
        
        //places stuff -> viewmodel / services
        placesClient = GMSPlacesClient()
    }
    
    //MARK: TableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier)
        cell!.textLabel?.attributedText = places[indexPath.row].attributedFullText
        return cell!
    }
    
    //MARK: SearchBarDelegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) -> Void {
        
        let northEast = CLLocationCoordinate2DMake(paperlessPostLocation.coordinate.latitude + 1, paperlessPostLocation.coordinate.longitude + 1)
        let southWest = CLLocationCoordinate2DMake(paperlessPostLocation.coordinate.latitude - 1, paperlessPostLocation.coordinate.longitude - 1)
        let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.Establishment
        if searchText.characters.count > 0 {
            print("Searching for '\(searchText)'")
            placesClient?.autocompleteQuery(searchText, bounds: bounds, filter: filter, callback: { (results, error) -> Void in
                
                if error != nil {
                    print("Autocomplete error \(error) for query '\(searchText)'")
                    return
                }
                
                print("Populating results for query '\(searchText)'")
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

