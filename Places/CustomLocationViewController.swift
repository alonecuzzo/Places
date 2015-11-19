//
//  CustomLocationViewController.swift
//  Places
//
//  Created by Sarah Griffis on 11/3/15.
//  Copyright © 2015 Code Mitten. All rights reserved.
//

import UIKit
import SnapKit


class CustomLocationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    private let tableView = UITableView ()
    private let CellIdentifier = "CellIdentifier"
    
    enum CustomLocationCell: Int {
    
        case VenueName = 0, Address = 1, City = 2, State = 3, ZipCode = 4
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.tableView)

        tableView.registerClass(CustomLocationTableViewCell.classForCoder(), forCellReuseIdentifier: CellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.rowHeight = 44

        setup()

    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        self.tableView.viewWithTag(1)?.becomeFirstResponder()
        
    }
    
    func setup() -> Void {
        
        tableView.snp_makeConstraints { (make) -> Void in
            
            make.bottom.right.left.equalTo(self.view)
            make.top.equalTo(self.view.snp_top)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.contentSize = CGSize(width: tableView.contentSize.width, height: tableView.contentSize.height + 100)
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
                cell.textfield.returnKeyType = .Next
                cell.textfield.tag = indexPath.row + 1
            
            case CustomLocationCell.Address.rawValue:
                cell.textfield.placeholder = "Address"
                cell.textfield.returnKeyType = .Next
                cell.textfield.tag = indexPath.row + 1
            
            case CustomLocationCell.City.rawValue:
                cell.textfield.placeholder = "City/Town"
                cell.textfield.returnKeyType = .Next
                cell.textfield.tag = indexPath.row + 1
            
            case CustomLocationCell.State.rawValue:
                cell.textfield.placeholder = "State"
                cell.textfield.returnKeyType = .Next
                cell.textfield.tag = indexPath.row + 1
            
            case CustomLocationCell.ZipCode.rawValue:
                cell.textfield.placeholder = "Zip/Postal Code"
                cell.textfield.returnKeyType = .Done
                cell.textfield.tag = indexPath.row + 1
            
            default:
                cell.textfield.placeholder = "Other"
            
        }
        
        //cell.textfield.tag = CustomLocationCell.VenueName.rawValue + 1
        cell.textfield.delegate = self
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        return cell
    }
    
    //MARK: tableViewDelegate
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 50
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
        
        return 75
    }
    
    //MARK: textfieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {

        
        let nextTag = textField.tag + 1
        
        if let nextTextField = tableView.viewWithTag(nextTag) {
                nextTextField.becomeFirstResponder()
        }
    
        return true
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
        label.font = UIFont (name: "HelveticaNeue-Light", size: 20)
        backbutton.setImage(UIImage(named: "icon-backArrow-black"), forState: UIControlState.Normal)
        
        self.backgroundColor = UIColor.whiteColor()
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
    }
}


class CustomLocationTableViewCell: UITableViewCell {
    
    var textfield = UITextField(frame: CGRectZero)
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        textfield.font = UIFont (name: "HelveticaNeue-Light", size: 16)
        textfield.autocorrectionType = .No
        textfield.autocapitalizationType = .Words

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
        
        make.right.equalTo(self)
        
        make.centerY
            .equalTo(self)
        
    }
}