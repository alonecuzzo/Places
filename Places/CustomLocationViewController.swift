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
    
    private let tableView = UITableView ()
    private let CellIdentifier = "CellIdentifier"
    
    
//    private let headerView: UIView = {
//    
//        let h = UIView(frame: CGRectZero)
//        h.translatesAutoresizingMaskIntoConstraints = false
//
//        let label = UILabel(frame: CGRectZero)
//        label.text = "Add custom location"
//        
//        h.frame = CGRect(x: 0, y: 0, width: 300, height: 55)
//        
//        h.addSubview(label)
//
//        
////        h.snp_makeConstraints(closure: { (make) -> Void in
////            
////            make.edges.equalTo(h)
////        })
//        
//        
//        return h
//    }()
    
//    private let headerViewLabel: UILabel = {
//    
//        let label = UILabel(frame: CGRectZero)
//        label.text = "Add custom location"
//    }()
    
    enum CustomLocationCell: Int {
    
        case VenueName = 0, Address = 1, City = 2, State = 3, ZipCode = 4
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//        //need to force redraw here, then hedder is guaranteed to be attached to tableView
//        tableView.setNeedsLayout()
//        tableView.layoutIfNeeded()
//        
//        headerView.snp_makeConstraints { (make) -> Void in
//            make.top.equalTo(self.tableView)
//            make.width.equalTo(self.view)
//            make.height.equalTo(55)
//            make.centerX.equalTo(self.view)
//        }
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.tableView)

        tableView.registerClass(CustomLocationTableViewCell.classForCoder(), forCellReuseIdentifier: CellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
    
        setup()
        



    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func setup() -> Void {
        

        
        tableView.snp_makeConstraints { (make) -> Void in
            
            make.bottom.right.left.equalTo(self.view)
            make.top.equalTo(self.view.snp_top)
        }
        
       
//        headerView.snp_makeConstraints { (make) -> Void in
//            
//            make.top
//                .left
//                .equalTo(0)
//            
//            make.right.equalTo(tableView)
//            
//            make.bottom.equalTo(55)
//        }
        
//        self.headerView.snp_makeConstraints { (make) -> Void in
//            
//            make.width.equalTo(self.tableView)
//            make.height.equalTo(44)
//            make.top.equalTo(self.tableView)
//                //.offset(-44)
////            make.width.equalTo(self.view)
////            make.height.equalTo(44)
////            make.centerX.equalTo(self.view)
//            
//
//        }
        
        
    }
    
    
    
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
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 55
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let t = customTableHeaderView(frame: CGRectZero)
        t.backbutton.addTarget(self, action: "pressedBackButton:", forControlEvents: .TouchUpInside)
        return t
    }
    
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    
        return saveButton(frame: CGRectZero)
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 55
    }
    
    //MARK: pressedBackButton
    func pressedBackButton(sender: UIButton!){
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}


class saveButton: UIView {
    
    let button = UIButton(frame: CGRectZero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        button.setTitle("SAVE", forState: .Normal)
        button.backgroundColor = UIColor.blackColor()
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = UIFont (name: "HelveticaNeue-Medium", size: 12)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addSubview(button)
        
        button.frame = CGRect(x: self.frame.width / 2 - 160 / 2, y: self.frame.height / 2 - 44 / 2, width: 160, height: 44)
    }

}

class customTableHeaderView: UIView {
    
    let label = UILabel(frame: CGRectZero)
    let backbutton = UIButton(frame: CGRectZero)
 

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        label.text =  "Add custom location"
        label.textAlignment = .Center
        backbutton.setImage(UIImage(named: "icon-backArrow-black"), forState: UIControlState.Normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        label.frame = self.frame
        backbutton.frame = CGRect(x: 16, y: 0, width: 20, height: self.frame.height)
        
        self.addSubview(label)
        self.addSubview(backbutton)
        
        
        let border = CALayer()
        let width = CGFloat(0.8)
        
        //default gray color on UITableViewSeparator
        border.borderColor = UIColor(red: 0.783922, green: 0.780392, blue: 0.8, alpha: 1.0).CGColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}


class CustomLocationTableViewCell: UITableViewCell {
    
    var textfield = UITextField(frame: CGRectZero)
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        //contentView.addSubview(textfield)
        textfield.font = UIFont (name: "HelveticaNeue", size: 16)
        self.selectionStyle = .None
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