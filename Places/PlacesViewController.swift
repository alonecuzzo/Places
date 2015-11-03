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
import RxSwift
import RxCocoa

//model for our places of interest
struct Place {

    let name: String
//    let address: String
//    let cityTown: String
//    let state: String
//    let zip: UInt
}

//google maps extension
extension Place {
    init(prediction: GMSAutocompletePrediction) {
       self.name = prediction.attributedFullText!.string
    }
}


//handles conversion of results to -> places
class PlacesResultViewModel {
    
}

class PlacesService {
    static let sharedAPI = PlacesService()
    let placesClient: GMSPlacesClient
    
    private init() {
        placesClient = GMSPlacesClient()
    }
    
    func getResults(query: String, location: CLLocation) -> Observable<[GMSAutocompletePrediction]> {
        return create { observer in
            
            let API = PlacesService.sharedAPI
            let northEast = CLLocationCoordinate2DMake(location.coordinate.latitude + 1, location.coordinate.longitude + 1)
            let southWest = CLLocationCoordinate2DMake(location.coordinate.latitude - 1, location.coordinate.longitude - 1)
            let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
            let filter = GMSAutocompleteFilter()
            filter.type = GMSPlacesAutocompleteTypeFilter.Establishment
            if query.characters.count > 0 {
                print("Searching for '\(query)'")
                API.placesClient.autocompleteQuery(query, bounds: bounds, filter: filter, callback: { (results, error) -> Void in
                    
                    if error != nil {
                        print("Autocomplete error \(error) for query '\(query)'")
                        return
                    }
                    
                    func isPrediction(obj: AnyObject) -> Bool {
                        guard let _ = obj as? GMSAutocompletePrediction else {
                            return false
                        }
                        return true
                    }
                    
                    print("Populating results for query '\(query)'")
                    let places = results!.filter { isPrediction($0) }.map { $0 as! GMSAutocompletePrediction }
                    observer.on(Event.Next(places))
//                    for result in results! {
//                        if let result = result as? GMSAutocompletePrediction {
//                            self.places.append(result)
//                        }
//                    }
//                    self.tableView.reloadData()
                })
            } else {
                //nothing back
//                self.places = [GMSAutocompletePrediction]()
//                self.tableView.reloadData()
            }
           
            
            return NopDisposable.instance
        }
    }
    
}

struct PlacesSearchViewModel {
    
    //MARK: Property
    let places: Driver<[Place]>
//    let searchText: Driver<String>
//    let location = Variable(CLLocation(latitude: 40.708882, longitude: -74.0136213))
    let bag = DisposeBag()
    
    let currentLocation: Driver<CLLocation>
    
    
    //init with location - will fix later
    
    //MARK: Method
    init(searchText: Driver<String>, location: Driver<CLLocation>) {
        
        self.currentLocation = location
        
        let API = PlacesService.sharedAPI
//        let localeLocation = 
        
//        let m = 
        
        self.places = searchText
                .throttle(0.3, MainScheduler.sharedInstance)
                .distinctUntilChanged()
                .map { query in
                    API.getResults(query, location: CLLocation())
                    .retry(3)
                    .startWith([])
                    .asDriver(onErrorJustReturn: [])
                }
                .switchLatest()
                .map { results in
                    results.map {
                        Place(prediction: $0)
                    }
                }
    }
}

class PlacesViewController: UIViewController {
    
    //MARK: Property
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let locationManager = CLLocationManager()
    private let CellIdentifier = "CellIdentifier"
    let disposeBag = DisposeBag()
    var viewModel: PlacesSearchViewModel!
    
    //Testing @40.708882,-74.0136213
    private let paperlessPostLocation = CLLocation(latitude: 40.708882, longitude: -74.0136213)
    
    
    //MARK: Method
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
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
        
        //Bindings
        viewModel = PlacesSearchViewModel(searchText: searchBar.rx_text.asDriver())
        viewModel.places
            .drive(tableView.rx_itemsWithCellIdentifier(CellIdentifier)) { (_, place, cell: UITableViewCell) in
                cell.textLabel?.text = place.name
            }
            .addDisposableTo(disposeBag)
        
//        locationManager.rx_didUpdateLocations.asDriver(onErrorJustReturn: [])
    }
}

