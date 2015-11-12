//
//  CustomLocationViewController.swift
//  Places
//
//  Created by Sarah Griffis on 11/3/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import UIKit
import SnapKit


class CustomLocationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView = UITableView()
    private let CellIdentifier = "CellIdentifier"
    
    enum CustomLocationCell: Int {
    
        case VenueName = 0, Address = 1, City = 2, State = 3, ZipCode = 4
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(CustomLocationTableViewCell.classForCoder(), forCellReuseIdentifier: CellIdentifier)
        
        //view.addSubview(tableView)
        setup()
    }
    
    func setup() -> Void {
        
        [tableView].forEach { self.view.addSubview($0) }
        
        tableView.snp_makeConstraints { (make) -> Void in
            
            make.left
                .right
                .bottom
                .equalTo(view)
            
            make.top
                .equalTo(self.view.snp_top)
                .offset(topLayoutGuide.length)
                .priorityHigh()
        }
    }
    
//    override func viewDidLayoutSubviews() {
//        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
//    }
    
    
    //MARK: tableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! CustomLocationTableViewCell
        
        switch indexPath.row {
            case CustomLocationCell.VenueName.rawValue :
                cell.textfield.placeholder = "Venue Name"
            
            case CustomLocationCell.Address.rawValue:
                cell.textfield.placeholder = "Address"
            
            case CustomLocationCell.City.rawValue:
                cell.textfield.placeholder = "City/Town"
            
            case CustomLocationCell.State.rawValue:
                cell.textfield.placeholder = "State"
            
            case CustomLocationCell.ZipCode.rawValue:
                cell.textfield.placeholder = "Zip/Postal Code"
            
            default:
                cell.textfield.placeholder = "Other"
            
        }
        
        return cell
    }
    
    //MARK: tableViewDelegate
//    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        <#code#>
//    }


}


class CustomLocationTableViewCell: UITableViewCell {
    
    let label = UILabel(frame: CGRectZero)
    var textfield = UITextField(frame: CGRectZero)
    
    
    override func layoutSubviews() {
        //textfield.frame = contentView.frame
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        //contentView.addSubview(textfield)
        textfield.font = UIFont (name: "HelveticaNeue", size: 16)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setup() {
        [textfield].forEach { self.addSubview($0) }
    }
    
    override func didMoveToSuperview() {
        
        textfield.snp_makeConstraints { make in
            self.setTextFieldConstraints(make)
        }
        
    }
    
    
    func setTextFieldConstraints(make: ConstraintMaker) {
        
        make.left
            .equalTo(self)
            .inset(16)
        
        make.centerY
            .equalTo(self)
        
    }
}