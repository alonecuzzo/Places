//
//  PlacesAutoCompleteViewController.swift
//  Places
//
//  Created by Jabari Bell on 11/2/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import SnapKit
import RxSwift
import RxCocoa


public class PlacesAutoCompleteViewController: UIViewController {
    
    //MARK: Property
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let locationManager = CLLocationManager()
    private let CellIdentifier = "CellIdentifier"
    let disposeBag = DisposeBag()
    var viewModel: GooglePlacesSearchViewModel!
    
    
    //Testing @40.708882,-74.0136213
    private let paperlessPostLocation = CLLocation(latitude: 40.708882, longitude: -74.0136213)
    
    
    //MARK: Method
    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
//    public init () {
//        super.init()
//    }

    required public init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    private func setup() -> Void {
        
        //View stuff
        view.addSubview(tableView)
        tableView.tableHeaderView = searchBar
        
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: CellIdentifier)
        
        tableView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(view)
        }
        
        searchBar.snp_makeConstraints { (make) -> Void in
            make.left.right.equalTo(view)
            make.top.equalTo(0)
            make.height.equalTo(55)
        }
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        
        let location = Variable(CLLocation())
        
        viewModel = GooglePlacesSearchViewModel(searchText: searchBar.rx_text.asDriver(), currentLocation: location, service: GooglePlacesSearchService.sharedAPI)
    
        viewModel.places
            .drive(tableView.rx_itemsWithCellIdentifier(CellIdentifier)) { (_, place, cell: UITableViewCell) in
                cell.textLabel?.text = place.name.value //i'm not sure that i want the vc to know about the model type
            }
            .addDisposableTo(disposeBag)
        
        locationManager.rx_didUpdateLocations
            .distinctUntilChanged({ (lhs, rhs) -> Bool in
                return lhs.first?.coordinate.latitude == rhs.first?.coordinate.latitude
                        && lhs.first?.coordinate.longitude == rhs.first?.coordinate.longitude
            })
            .subscribeNext { [weak self] locations -> Void in
                self?.locationManager.stopUpdatingLocation()
                guard let currentLocation = locations.first else { return }
                location.value = currentLocation //there is probably a more reactive way to write this
            }
            .addDisposableTo(disposeBag)
        
        //error
        //did change authorization status
        
        locationManager.startUpdatingLocation()
    }
    

    override public func viewDidAppear(animated: Bool) -> Void {
        super.viewDidAppear(animated)
        
        searchBar.becomeFirstResponder()
    }
    
    override public func prefersStatusBarHidden() -> Bool {
        return true
    }
}

