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

//protocol Predictable {
//    typealias Prediction
//}
//
//protocol PlacesSearchable: Predictable {
//    func getResults(query: String, location: CLLocation) -> Observable<[Prediction]>
//}


class GooglePlacesSearchService {
    
    //MARK: Property
    static let sharedAPI = GooglePlacesSearchService()
    let placesClient: GMSPlacesClient
    
    
    //MARK: Method
    private init() {
        placesClient = GMSPlacesClient()
    }
    
    func getResults(query: String, location: CLLocation) -> Observable<[GMSAutocompletePrediction]> {
        return create { observer in
            
            let API = self
            let northEast = CLLocationCoordinate2DMake(location.coordinate.latitude + 1, location.coordinate.longitude + 1)
            let southWest = CLLocationCoordinate2DMake(location.coordinate.latitude - 1, location.coordinate.longitude - 1)
            let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
            let filter = GMSAutocompleteFilter()
            filter.type = GMSPlacesAutocompleteTypeFilter.Establishment
            if query.characters.count > 0 {
                print("Searching for '\(query)'")
                API.placesClient.autocompleteQuery(query, bounds: bounds, filter: filter, callback: { (results, error) -> Void in
                    
                    if let error = error {
                        observer.on(.Error(error))
                        return
                    }
                    
                    print("Populating results for query '\(query)'")
                    let places = results!.filter { $0 is GMSAutocompletePrediction }.map { $0 as! GMSAutocompletePrediction }
                    observer.on(Event.Next(places))
                })
            }
            
            return NopDisposable.instance
        }
    }
    
}


//To test, given a location, our array of places should be what we expect
//going to need to be able to swap out the service -> maybe extract it into another class
//apiForViewModel? will allow for plug & play
struct GooglePlacesSearchViewModel {
    
    //MARK: Property
    let places: Driver<[Place]>
    let bag = DisposeBag()
    
    
    //MARK: Method
    init(searchText: Driver<String>, currentLocation: Variable<CLLocation>, service: GooglePlacesSearchService = GooglePlacesSearchService.sharedAPI) {
        
        let API = service //now we can pass whatever service in we want - need to give it a protocol assignment
        self.places = searchText
                .throttle(0.3, MainScheduler.sharedInstance)
                .distinctUntilChanged()
                .map { query in
                    API.getResults(query, location: currentLocation.value)
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
    var viewModel: GooglePlacesSearchViewModel!
    
    
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
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        
        let location = Variable(CLLocation())
        
        viewModel = GooglePlacesSearchViewModel(searchText: searchBar.rx_text.asDriver(), currentLocation: location)
    
        viewModel.places
            .drive(tableView.rx_itemsWithCellIdentifier(CellIdentifier)) { (_, place, cell: UITableViewCell) in
                cell.textLabel?.text = place.name //i'm not sure that i want the vc to know about the model type
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
}

