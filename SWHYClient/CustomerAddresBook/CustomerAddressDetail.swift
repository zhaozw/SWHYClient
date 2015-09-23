//
//  CustomerAddressDetail.swift
//  SWHYClient
//
//  Created by sunny on 4/29/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//

import UIKit
import Foundation

class CustomerAddressDetail: UIViewController {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSex: UILabel!
    @IBOutlet weak var lblCompany: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblJobTitle: UILabel!
    @IBOutlet weak var lblLinePhone: UILabel!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var lblMainPhone: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblImportant: UILabel!
    @IBOutlet weak var lblGroup: UILabel!
    @IBOutlet weak var lblCustomerManager: UILabel!
    
    @IBOutlet weak var lblCustLevel: UILabel!
    
    
    
    @IBOutlet weak var imgLinePhone: UIImageView!
    
    @IBOutlet weak var imgCompTel: UIImageView!
    
    @IBOutlet weak var imgMobile: UIImageView!
    @IBOutlet weak var imgMessage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.contentView.frame.origin.y = 30
        println("inner address detail view did load")
        // Do any additional setup after loading the view.
        //self.scrollview.scrollEnabled = true
        let item:CustomerAddressItem =  Message.shared.curCustomerAddressItem
        self.title = item.name
        self.lblName.text = item.name
        println(item.sex)
        self.lblSex.text = item.sex
        self.lblCompany.text = item.comp
        self.lblLevel.text = item.level
        
        self.lblJobTitle.text = item.jobtitle
        self.lblLinePhone.text = item.linetel
        self.lblMobile.text = item.mobile
        self.lblMainPhone.text = item.comptel
        self.lblEmail.text = item.email
        self.lblImportant.text = item.important
        self.lblGroup.text = item.group
        self.lblCustomerManager.text = item.managerlist
        self.lblCustLevel.text = item.custlevel
        
        
        
        let tap_linephone:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClick_LinePhone:")
        imgLinePhone.addGestureRecognizer(tap_linephone)
        
        
        let tap_mobile:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClick_Mobile:")
        imgMobile.addGestureRecognizer(tap_mobile)
        
        let tap_comptel:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClick_Comptel:")
        imgCompTel.addGestureRecognizer(tap_comptel)
        
        
        let tap_message:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClick_Message:")
        imgMessage.addGestureRecognizer(tap_message)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let backitem = UIBarButtonItem(title: Config.UI.PreNavItem, style: UIBarButtonItemStyle.Plain, target: self, action: "returnNavView")
        self.navigationItem.leftBarButtonItem = backitem
        
        //let view:UIScrollView = self.contentView as! UIScrollView
        //view.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, 600)
        //self.scrollview.contentSize = CGSizeMake(600, 1200)
        //println(self.scrollview.contentSize)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        var navbar = self.navigationController?.navigationBar
        //println(self.navigationController?.navigationBar.frame.origin.y)
        //println(self.navigationController?.navigationBar.frame.height)
        var y = self.navigationController?.navigationBar.frame.origin.y 
        var h = self.navigationController?.navigationBar.frame.height
        var s = y! + h!
        self.contentView.frame.origin.y = s
        //self.scrollview.contentSize = CGSizeMake(200.0, 200.0)
        //println(self.scrollview.contentSize)
        //self.scrollview.frame.origin.y = s
        //println(self.scrollview.frame.origin.y)
        
    }
    
    
    func returnNavView(){
        println("click return button")
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    func onClick_LinePhone(sender:UITapGestureRecognizer!){
        let num = lblLinePhone?.text
        if num != nil {
            confirmCall(num!)
        }
    }

    func onClick_Mobile(sender:UITapGestureRecognizer!){
        let num = lblMobile?.text
        if num != nil {
            confirmCall(num!)
        }
    }
    
    func onClick_Comptel(sender:UITapGestureRecognizer!){
        let num = lblMainPhone?.text
        if num != nil {
            confirmCall(num!)
        }
    }

    func onClick_Message(sender:UITapGestureRecognizer!){
        let num = lblMobile?.text
        if num != nil {
            confirmSMS(num!)
        }
    }
    
override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?){
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
}


convenience init() {
    
    self.init(nibName: "CustomerAddressDetail", bundle: nil)
    println("over ride init =======after=======")
    //self.init(nibName: "LaunchScreen", bundle: nil)
    
}
override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
}



required init(coder aDecoder: NSCoder) {
    
    fatalError("init(coder:) has not been implemented")
    
}

func confirmCall(num:String){
    
    if num != "" && num != "-" {
        let btn_OK:PKButton = PKButton(title: "拨打",
            action: { (messageLabel, items) -> Bool in
                let urlstr = "tel://\(num)"
                println("=========click==========\(urlstr)")
                var url1 = NSURL(string: urlstr)
                UIApplication.sharedApplication().openURL(url1!)
                
                
                //记录客户拨打日志
                let logItem = CustomerLogItem()
                logItem.user = NSUserDefaults.standardUserDefaults().objectForKey("UserName") as! String
                logItem.module = "CustomerAddressDetail"
                logItem.customerid = Message.shared.curCustomerAddressItem.customerid
                logItem.phonenumber = num
                logItem.type = "2"
                logItem.startdatetime = Util.getCurDateString()
                logItem.enddatetime = ""
                logItem.duration = NSUserDefaults.standardUserDefaults().objectForKey("CallDuration") as! String          
                
                DBAdapter.shared.syncCustomerLogItem(logItem)
                
                
                return true
            },
            fontColor: UIColor(red: 0, green: 0.55, blue: 0.9, alpha: 1.0),
            backgroundColor: nil)
        
        // call alert
        PKNotification.alert(
            title: "通话确认",
            message: "确认拨打电话:\(num)?",
            items: [btn_OK],
            cancelButtonTitle: "取消",
            tintColor: nil)
        
    }
    
}

func confirmSMS(num:String){
    
    if num != "" {
        let btn_OK:PKButton = PKButton(title: "短信确认",
            action: { (messageLabel, items) -> Bool in
                let urlstr = "sms://\(num)"
                println("=========sms==========\(urlstr)")
                var url1 = NSURL(string: urlstr)
                UIApplication.sharedApplication().openURL(url1!)
                return true
            },
            fontColor: UIColor(red: 0, green: 0.55, blue: 0.9, alpha: 1.0),
            backgroundColor: nil)
        
        // call alert
        PKNotification.alert(
            title: "短信确认",
            message: "确认发送短信至:\(num)?",
            items: [btn_OK],
            cancelButtonTitle: "取消",
            tintColor: nil)
    }
    
}
/*
// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
// Get the new view controller using segue.destinationViewController.
// Pass the selected object to the new view controller.
}
*/

}
