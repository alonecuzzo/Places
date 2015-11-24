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


struct PlacesAutoCompleteTableViewCellFactory {
    
    static func itemCellFor(tableView: UITableView, index: Int, item: GooglePlacesDatasourceItem) -> UITableViewCell {
        switch item {
        case let .PlaceCell(place):
            return PlacesAutoCompleteTableViewCellFactory.placeCellFor(tableView, index: index, place: place)
        case .CustomPlaceCell:
            return PlacesAutoCompleteTableViewCellFactory.customPlaceCell()
        }
    }
    
    private static func placeCellFor(tableView: UITableView, index: Int, place: Place) -> UITableViewCell {
        return UITableViewCell()
    }
    
    private static func customPlaceCell() -> UITableViewCell {
        //need to dequeue from tableview 
        return AddCustomLocationCell()
    }
}


public class PlacesAutoCompleteViewController: UIViewController {
    
    
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
    
    //MARK: Property
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let locationManager = CLLocationManager()
    private let PlaceCellIdentifier = "PlaceCellIdentifier"
    private let CustomPlaceCellIdentifier = "CustomPlaceCellIdentifier"
    let disposeBag = DisposeBag()
    var viewModel: GooglePlacesSearchViewModel!
    
    
    //Testing @40.708882,-74.0136213
    private let paperlessPostLocation = CLLocation(latitude: 40.708882, longitude: -74.0136213)
    
    
    //MARK: Method
    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    //its forcing me to use this since i want to init from the outside dang
//    public init () {
//        let className = NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last
//        super.init(nibName: className, bundle: NSBundle(forClass: self.dynamicType))
//    }

//    required public init?(coder aDecoder: NSCoder) {
////        fatalError("init(coder:) has not been implemented")
//        super.init(coder: aDecoder)
//    }
    
    private func setup() -> Void {
        
        //View stuff
        view.addSubview(tableView)
        tableView.tableHeaderView = searchBar
        
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: PlaceCellIdentifier)
        
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
        
//        let datasource = RxTableViewReactiveArrayDataSource(cellFactory
    
//        viewModel.items
//            .drive(tableView.rx_itemsWithCellIdentifier(PlaceCellIdentifier)) { (_, item, cell: UITableViewCell) in
                //cell factory
//                cell.textLabel?.text = place.name.value //i'm not sure that i want the vc to know about the model type
//            }
//            .addDisposableTo(disposeBag)
        
        
        viewModel.items
            .drive(tableView.rx_itemsWithCellFactory) { (tv, idx, item) -> UITableViewCell in
                PlacesAutoCompleteTableViewCellFactory.itemCellFor(tv, index: idx, item: item)
        }.addDisposableTo(disposeBag)
        
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
