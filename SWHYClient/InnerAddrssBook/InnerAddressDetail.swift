//
//  InnerAddressDetail.swift
//  SWHYClient
//
//  Created by sunny on 4/29/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//

import UIKit
import Foundation

class InnerAddressDetail: UIViewController {
    
    @IBOutlet var scrollview: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEID: UILabel!
    @IBOutlet weak var lblDept: UILabel!
    @IBOutlet weak var lblLinePhone: UILabel!
    @IBOutlet weak var lblPhone_DX: UILabel!
    @IBOutlet weak var lblDh_DX: UILabel!
    @IBOutlet weak var lblPhone_YD: UILabel!
    @IBOutlet weak var lblDh_YD: UILabel!
    @IBOutlet weak var lblPhone_Home: UILabel!
    @IBOutlet weak var lblPhone_Other: UILabel!
    
    @IBOutlet weak var lblResearchTeam: UILabel!
    
    @IBOutlet weak var imgLinePhone: UIImageView!
    @IBOutlet weak var imgDXPhone: UIImageView!
    @IBOutlet weak var imgYDPhone: UIImageView!
    @IBOutlet weak var imgHomePhone: UIImageView!
    @IBOutlet weak var imgOtherPhone: UIImageView!
    
  
    @IBOutlet weak var imgMsgDXPhone: UIImageView!
    @IBOutlet weak var imgMsgYDPhone: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.contentView.frame.origin.y = 30
        print("inner address detail view did load")
        // Do any additional setup after loading the view.
        //self.scrollview.scrollEnabled = true
        let item:InnerAddressItem =  Message.shared.curInnerAddressItem
        self.title = item.name
        self.lblName.text = item.name
        self.lblEID.text = item.empid
        self.lblDept.text = item.dept
        self.lblLinePhone.text = item.linetel
        self.lblPhone_DX.text = item.mobiletelecom
        self.lblDh_DX.text = item.mobiletelecom1
        self.lblPhone_YD.text = item.mobile
        self.lblDh_YD.text = item.mobile1
        self.lblPhone_Home.text = item.homephone
        self.lblPhone_Other.text = item.othertel
        self.lblResearchTeam.text = item.researchteam
        
        let tap_linephone:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClick_LinePhone:")
        //tap.numberOfTapsRequired = 1
        //tap.numberOfTouchesRequired = 1
        imgLinePhone.addGestureRecognizer(tap_linephone)
        
        
        let tap_dxphone:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClick_DXPhone:")
        imgDXPhone.addGestureRecognizer(tap_dxphone)
        
        let tap_ydphone:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClick_YDPhone:")
        imgYDPhone.addGestureRecognizer(tap_ydphone)
        
        let tap_homephone:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClick_HomePhone:")
        imgHomePhone.addGestureRecognizer(tap_homephone)
        
        let tap_otherphone:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClick_OtherPhone:")
        imgOtherPhone.addGestureRecognizer(tap_otherphone)
    
        let tap_msgdxphone:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClick_MsgDXPhone:")
        imgMsgDXPhone.addGestureRecognizer(tap_msgdxphone)
        
        let tap_msgydphone:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClick_MsgYDPhone:")
        imgMsgYDPhone.addGestureRecognizer(tap_msgydphone)
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
        let y = self.navigationController?.navigationBar.frame.origin.y 
        let h = self.navigationController?.navigationBar.frame.height
        let s = y! + h!
        self.contentView.frame.origin.y = s
        //self.scrollview.contentSize = CGSizeMake(200.0, 200.0)
        //println(self.scrollview.contentSize)
        //self.scrollview.frame.origin.y = s
        //println(self.scrollview.frame.origin.y)
        
    }

    
    func returnNavView(){
        print("click return button")
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    func onClick_LinePhone(sender:UITapGestureRecognizer!){
        let num = lblLinePhone?.text
        if num != nil {
            confirmCall(num!)
        }
    }
    
    func onClick_DXPhone(sender:UITapGestureRecognizer!){
        let num = lblPhone_DX?.text
        if num != nil {
            confirmCall(num!)
        }
    }
    
    func onClick_YDPhone(sender:UITapGestureRecognizer!){
        let num = lblPhone_YD?.text
        if num != nil {
            confirmCall(num!)
        }
    }
    
    func onClick_HomePhone(sender:UITapGestureRecognizer!){
        let num = lblPhone_Home?.text
        if num != nil{
            confirmCall(num!)
        }}
    
    func onClick_OtherPhone(sender:UITapGestureRecognizer!){
        let num = lblPhone_Other?.text
        if num != nil{
            confirmCall(num!)
        }}
    
    func onClick_MsgDXPhone(sender:UITapGestureRecognizer!){
        let num = lblPhone_DX?.text
        if num != nil {
            confirmSMS(num!)
        }
    }
    
    func onClick_MsgYDPhone(sender:UITapGestureRecognizer!){
        let num = lblPhone_YD?.text
        if num != nil {
            confirmSMS(num!)
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
        
    convenience init() {
        //print(" override init =======begin====")
        self.init(nibName: "InnerAddressDetail", bundle: nil)
        //print("over ride init =======after=======")
        //self.init(nibName: "LaunchScreen", bundle: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    func confirmCall(num:String){
       
        if num != "" {
            let btn_OK:PKButton = PKButton(title: "拨打",
                action: { (messageLabel, items) -> Bool in
                    let urlstr = "tel://\(num)"
                    //print("=========click==========\(urlstr)")
                    let url1 = NSURL(string: urlstr)
                    UIApplication.sharedApplication().openURL(url1!)
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
                    //print("=========sms==========\(urlstr)")
                    let url1 = NSURL(string: urlstr)
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
