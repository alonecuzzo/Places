//
//  PlacesAutoCompleteViewController.swift
//  Places
//
//  Created by Jabari Bell on 11/2/15.
//  Copyright © 2015 Paperless Post. All rights reserved.
//

import UIKit
import GoogleMaps
import SnapKit
import RxSwift
import RxCocoa


public class PlacesAutoCompleteViewController: UIViewController, Exitable {
    
    //MARK: Property
    let exitingEvent: Variable<ExitingEvent?> = Variable(nil)
    var viewModel: GooglePlacesSearchViewModel!
    
    private let presenter = PlacesAutoCompletePresenter()
    private let autoCompleteConfig: PlacesAutoCompleteConfig
    private let tableView = UITableView()
    private let autoCompleteSearchView = PlacesAutoCompleteSearchView()
    private let userCoordinate: Variable<PlaceCoordinate> = Variable(PlaceCoordinate(latitude: 0, longitude: 0))
    private let searchText = Variable("")
    private var locationManager: PlacesCoreLocationManager!
    private lazy var poweredByGoogleView = UIImageView(image: UIImage(named: "poweredByGoogle"))
    private let locationPrompt = LocationSettingsPromptView(frame: CGRectZero)
    private let disposeBag = DisposeBag()
    
    
    //MARK: Method
    init(autoCompleteConfig: PlacesAutoCompleteConfig) {
        self.autoCompleteConfig = autoCompleteConfig
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        self.autoCompleteConfig = PlacesAutoCompleteConfigType.Default.config
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() -> Void {
        setupTableView()
        setupLocation()
        setupViewModel()
        setupLocationSettingsView()
        setupPoweredByGoogleView()
    }

    override public func viewDidAppear(animated: Bool) -> Void {
        super.viewDidAppear(animated)
        autoCompleteSearchView.textField.becomeFirstResponder()
    }
    
    override public func prefersStatusBarHidden() -> Bool { return true }
    
    deinit { exitingEvent.value = .Cancel }
}

///MARK: TableView Setup
extension PlacesAutoCompleteViewController {
    
    private func setupTableView() -> Void {
        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(tableView)
        view.addSubview(autoCompleteSearchView)
        view.addSubview(locationPrompt)
        
        let emptyPlace = GooglePlacesDatasourceItem.PlaceCell(_EventPlace())
        tableView.registerClass(emptyPlace.cellClass, forCellReuseIdentifier: emptyPlace.cellIdentifier)
        tableView.registerClass(GooglePlacesDatasourceItem.CustomPlaceCell.cellClass, forCellReuseIdentifier: GooglePlacesDatasourceItem.CustomPlaceCell.cellIdentifier)
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
        
        locationPrompt.snp_makeConstraints { (make) -> Void in
            make.left
                .right
                .equalTo(view)
            
            make.top
                .equalTo(view)
                .offset(125)
            
            make.bottom
                .equalTo(view)
        }
        
        //bindings
        let searchView = autoCompleteSearchView
        searchView.textField.rx_text <-> searchText
        
        searchView.searchIcon.rx_tap.subscribeNext { [weak self] in
            self?.searchText.value = ""
        }.addDisposableTo(disposeBag)
        
        searchText.asObservable().map { $0.characters.count > 0 }
            .subscribeNext { searchView.searchIcon.enabled = $0 }
            .addDisposableTo(disposeBag)
        
    }
}

///MARK: ViewModel Setup
extension PlacesAutoCompleteViewController {
    
    private func setupViewModel() -> Void {
        let screenHeight = UIApplication.sharedApplication().windows.first?.frame.height
        let resultsDescription = PlacesAutoCompleteViewController.resultsDescriptionForScreenHeight(screenHeight!)
        let service = GooglePlacesSearchService(resultsDescription: resultsDescription)
        
        viewModel = GooglePlacesSearchViewModel(searchText: searchText.asObservable(), currentCoordinate: userCoordinate, service: service, throttleValue: autoCompleteConfig.throttleSpeed.rawValue, authorizationStatus: locationManager.authorizationStatus)
        
        viewModel.items
            .drive(tableView.rx_itemsWithCellFactory) { (tv, idx, item) -> UITableViewCell in
                PlacesAutoCompleteTableViewCellFactory.itemCellFor(tv, index: idx, item: item)
        }.addDisposableTo(disposeBag)
        
        let tv = tableView
        
        tableView.rx_itemSelected.subscribeNext { [unowned self] (indexPath) -> Void in
            do {
                let item: GooglePlacesDatasourceItem = try tv.rx_modelAtIndexPath(indexPath)
                self.presenter.presentViewControllerForItem(item, fromViewController: self)
            } catch {
               print("Error Presenting") //add an error here
            }
        }.addDisposableTo(disposeBag)
    }
    
    private class func resultsDescriptionForScreenHeight(height: CGFloat) -> AutoCompletePlaceNumberOfResultsDescription {
        let greaterThaniPhone5Height: CGFloat = 590
        return (height > greaterThaniPhone5Height) ? .Default : .Short
    }
}


///MARK: Core Location Setup
extension PlacesAutoCompleteViewController {
    
    private func setupLocation() -> Void {
        locationManager = PlacesCoreLocationManager(
            coordinateReceivedBlock: { [weak self] coordinate -> Void in
                guard let coordinate = coordinate else { return }
                self?.userCoordinate.value = coordinate
        })
        
        locationManager.authorizationStatus.asObservable().subscribeNext { [weak self] status -> Void in
            
                switch status {
                case .Authorized:
                    self?.locationPrompt.hidden = true
                    self?.poweredByGoogleView.hidden = false
                    
                case .Denied, .Unknown:
                    self?.locationPrompt.hidden = false
                    self?.poweredByGoogleView.hidden = true
                }
        }.addDisposableTo(disposeBag)
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


///MARK: Location Settings View Setup
extension PlacesAutoCompleteViewController {
    
    private func setupLocationSettingsView() -> Void {
        locationPrompt.button.rx_tap.subscribeNext {
            if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }.addDisposableTo(disposeBag)
    }
}
