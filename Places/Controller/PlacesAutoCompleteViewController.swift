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

public enum ExitingEvent {
    case AutoCompletePlace(Place), CustomPlace(Place), Cancel
}


public class PlacesAutoCompleteViewController: UIViewController, Exitable {
    
    //MARK: Property
    private let tableView = UITableView() 
    private let autoCompleteSearchView = PlacesAutoCompleteSearchView()
    
    private let userLocation = Variable(CLLocation())
    private var locationManager: PlacesCoreLocationManager!
    private let searchText = Variable("")
    
    let disposeBag = DisposeBag()
    
    var viewModel: GooglePlacesSearchViewModel!
    
    private lazy var poweredByGoogleView = UIImageView(image: UIImage(named: "poweredByGoogle"))
    
    let exitingEvent: Variable<ExitingEvent?> = Variable(nil)
    
    
    //MARK: Method
    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() -> Void {
        setupTableView()
        setupViewModel() //can also put in an extension returning configured tableview
        setupCoreLocation() //present w/ a local notification asking if we can use location - custom not system and THEN show the system if they say yes
        setupPoweredByGoogleView()
    }

    override public func viewDidAppear(animated: Bool) -> Void {
        super.viewDidAppear(animated)
        autoCompleteSearchView.textField.becomeFirstResponder()
    }
    
    override public func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    deinit {
        exitingEvent.value = .Cancel
    }
}

///MARK: TableView Setup
extension PlacesAutoCompleteViewController {
    private func setupTableView() -> Void {
        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(tableView)
        view.addSubview(autoCompleteSearchView)
        
        let emptyPlace = GooglePlacesDatasourceItem.PlaceCell(_Place())
        tableView.registerClass(emptyPlace.cellClass, forCellReuseIdentifier: emptyPlace.CellIdentifier)
        tableView.registerClass(GooglePlacesDatasourceItem.CustomPlaceCell.cellClass, forCellReuseIdentifier: GooglePlacesDatasourceItem.CustomPlaceCell.CellIdentifier)
        tableView.scrollEnabled = false
        tableView.rowHeight = PlacesViewStyleCatalog.LocationResultsRowHeight
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        autoCompleteSearchView.snp_makeConstraints { (make) -> Void in
            make.left
                .right
                .equalTo(view)
            
            make.top
                .equalTo(0)
            
            make.height
                .equalTo(PlacesViewStyleCatalog.AutoCompleteSearchViewHeight)
        }
        
        tableView.snp_makeConstraints { (make) -> Void in
            make.bottom
                .left
                .right
                .equalTo(view)
            
            make.top
                .equalTo(autoCompleteSearchView.snp_bottom)
        }
        
        //bindings
        let searchView = autoCompleteSearchView
        searchView.textField.rx_text <-> searchText
        
        searchView.searchIcon.rx_tap.subscribeNext { [weak self] in
            self?.searchText.value = ""
        }.addDisposableTo(disposeBag)
        
        searchText.map { $0.characters.count > 0 }
            .subscribeNext { searchView.searchIcon.enabled = $0 }
            .addDisposableTo(disposeBag)
    }
}

///MARK: ViewModel Setup
extension PlacesAutoCompleteViewController {
    
    private func setupViewModel() -> Void {
        
        viewModel = GooglePlacesSearchViewModel(searchText: searchText.asDriver(onErrorJustReturn: "Error"), currentLocation: userLocation, service: GooglePlacesSearchService.sharedAPI)
        
        viewModel.items
            .drive(tableView.rx_itemsWithCellFactory) { (tv, idx, item) -> UITableViewCell in
                PlacesAutoCompleteTableViewCellFactory.itemCellFor(tv, index: idx, item: item)
        }.addDisposableTo(disposeBag)
        
        let tv = tableView
        
        tableView.rx_itemSelected.subscribeNext { [weak self] (indexPath) -> Void in
            do {
                let item: GooglePlacesDatasourceItem = try tv.rx_modelAtIndexPath(indexPath)
                PlacesAutoCompletePresenter.sharedPresenter.presentViewControllerForItem(item, fromViewController: self!) //MAINTAIN INSTANCE HERE NO SINGLETON
            } catch {
               print("Error Presenting") //add an error here
            }
        }.addDisposableTo(disposeBag)
    }
}


///MARK: Core Location Setup
extension PlacesAutoCompleteViewController {
    
    private func setupCoreLocation() -> Void {
        
        locationManager = PlacesCoreLocationManager(locationReceivedBlock: { [weak self] (location) -> Void in
                guard let currentLocation = location else { return }
                self?.userLocation.value = currentLocation
        })
    }
}


///MARK: Powered By Google View Setup
extension PlacesAutoCompleteViewController {
    private func setupPoweredByGoogleView() -> Void {
        let googleView = poweredByGoogleView
        googleView.alpha = 0
        view.addSubview(googleView)
        onKeyboardDidShow { (notification) -> () in
            guard let keyboardFrame = notification.keyboardFrame else { return }
            googleView.frame = PlacesAutoCompleteViewController
                                .poweredByGoogleViewFrameForViewWithSize(
                                    googleView.frame.size,
                                    keyboardHeight: keyboardFrame.size.height,
                                    inParentViewWithSize: self.view.frame.size
                                )
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                googleView.alpha = 1
            })
        }.addDisposableTo(disposeBag)
    }
    
    private static func poweredByGoogleViewFrameForViewWithSize(viewSize: CGSize, keyboardHeight: CGFloat, inParentViewWithSize parentViewSize: CGSize) -> CGRect {
        let margin: CGFloat = 10
        return CGRect(x: parentViewSize.width - viewSize.width - margin, y: (parentViewSize.height - keyboardHeight) - viewSize.height - margin, width: viewSize.width, height: viewSize.height)
    }
}
