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
    private let disposeBag = DisposeBag()
    
    private var locationManager: PlacesCoreLocationManager!
    private lazy var poweredByGoogleView = UIImageView(image: UIImage(named: "poweredByGoogle"))
    private let locationPrompt = LocationSettingsPromptView(frame: CGRectZero)
    
    
    //MARK: Method
    init(autoCompleteConfig: PlacesAutoCompleteConfig) {
        self.autoCompleteConfig = autoCompleteConfig
        super.init(nibName: nil, bundle: nil)
        addDidBecomeActiveListener()
    }

    required public init?(coder aDecoder: NSCoder) {
        self.autoCompleteConfig = PlacesAutoCompleteConfigType.Default.config
        super.init(coder: aDecoder)
        addDidBecomeActiveListener()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() -> Void {
        setupTableView()
        setupViewModel()
        setupLocation()
        setupPoweredByGoogleView()
        setupLocationSettingsView()
    }

    override public func viewDidAppear(animated: Bool) -> Void {
        super.viewDidAppear(animated)

        autoCompleteSearchView.textField.becomeFirstResponder()
    }
    
    func applicationBecameActive() -> Void {
        guard let lm = locationManager else { return }
        switch lm.authorizationStatus {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            locationPrompt.hidden = true
            poweredByGoogleView.hidden = false
        default:
            locationPrompt.hidden = false
            poweredByGoogleView.hidden = true
        }
    }
    
    override public func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    private func addDidBecomeActiveListener() -> Void {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationBecameActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    private func removeDidBecomeActiveListener() -> Void {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    deinit {
        removeDidBecomeActiveListener()
        exitingEvent.value = .Cancel
    }
}

///MARK: TableView Setup
extension PlacesAutoCompleteViewController {
    private func setupTableView() -> Void {
        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(tableView)
        view.addSubview(autoCompleteSearchView)
        view.addSubview(locationPrompt)
        
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
        viewModel = GooglePlacesSearchViewModel(searchText: searchText.asDriver(), currentCoordinate: userCoordinate, service: service, throttleValue: autoCompleteConfig.throttleSpeed.rawValue)
        
        
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
        let alertConfig = autoCompleteConfig.alertConfigType.config
        let cancelHandler: UIAlertActionHandlerBlock = { action -> Void in
            print("cancelled location")
            //set default line for app
            //self!.button.hidden = false
        }
        
        locationManager = PlacesCoreLocationManager(
            coordinateReceivedBlock: { [weak self] coordinate -> Void in
                guard let coordinate = coordinate else { return }
                self?.userCoordinate.value = coordinate
            },
            internalAlertBlock: { [weak self] (manager) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    let alertController = UIAlertController(title: alertConfig.externalAlertTitle, message: alertConfig.externalAlertMessage, preferredStyle: UIAlertControllerStyle.Alert)
                    let defaultAction = UIAlertAction(title: "Allow", style: UIAlertActionStyle.Default) { action -> Void in
                        manager.requestAlwaysAuthorization()
                    }
                    let cancelAction = UIAlertAction(title: "Don't Allow", style: UIAlertActionStyle.Default, handler: cancelHandler)
                    alertController.addAction(cancelAction)
                    alertController.addAction(defaultAction)
                    manager.systemCancelAction = cancelHandler
                    self?.presentViewController(alertController, animated: true, completion: nil)
                }
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


///MARK: Location Settings View Setup
extension PlacesAutoCompleteViewController {
    private func setupLocationSettingsView() -> Void {
        
        locationPrompt.button.rx_tap.subscribeNext {
            if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
}


class LocationSettingsPromptView: UIView {
    
    //MARK: Property
    let button: UIButton = {
        let b = UIButton(frame: CGRectZero)
        b.setTitle("ENABLE LOCATION ACCESS", forState: .Normal)
        b.titleLabel!.font = PlacesViewStyleCatalog.EnableLocationButtonFont
        b.setTitleColor(UIColor.blackColor(), forState: .Normal)
        b.layer.borderColor = UIColor.blackColor().CGColor
        b.layer.borderWidth = PlacesViewStyleCatalog.EnableLocationButtonBorderWidth
        return b
    }()
    
    let text: UILabel = {
        let t = UILabel(frame: CGRectZero)
        t.text = PlacesViewStyleCatalog.EnableLocationTextText
        t.textColor = PlacesViewStyleCatalog.EnableLocationTextFontColor
        t.numberOfLines = 0
        t.font = PlacesViewStyleCatalog.EnableLocationTextFont
        t.textAlignment = NSTextAlignment.Center
        return t
    }()
    
    let icon: UIImageView = {
        let u = UIImageView(image: UIImage(named: "location-icon-large"))
        return u
    }()
    
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
        self.addSubview(button)
        self.addSubview(text)
        self.addSubview(icon)
        
        icon.snp_makeConstraints { (make) -> Void in
            make.top
                .equalTo(self)
            
            make.width
                .equalTo(PlacesViewStyleCatalog.EnableLocationIconWidth)
            
            make.height
                .equalTo(PlacesViewStyleCatalog.EnableLocationIconHeight)
            
            make.centerX
                .equalTo(self)
        }
        
        text.snp_makeConstraints { (make) -> Void in
            make.left
                .right
                .equalTo(self)
            
            make.top
                .equalTo(icon.snp_bottom)
                .offset(10)
            
            make.bottom
                .equalTo(button.snp_top)
                .offset(-20)
        }
        
        button.snp_makeConstraints { (make) -> Void in
            make.width
                .equalTo(PlacesViewStyleCatalog.EnableLocationButtonWidth)
            
            make.height
                .equalTo(PlacesViewStyleCatalog.EnableLocationButtonHeight)
            
            make.centerX
                .equalTo(self.center)
            
            
            make.top
                .equalTo(text.snp_bottom)

        }
    }
    
    
}
