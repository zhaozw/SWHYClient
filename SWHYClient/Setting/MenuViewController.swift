//
//  MenuViewController.swift
//  SWHYClient
//
//  Created by sunny on 5/14/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//

import Foundation
import Darwin

import UIKit

class MenuViewController: UIViewController{
    
    @IBOutlet weak var btnSetting: UIView!
    
    @IBOutlet weak var btnLogout: UIView!
    
    @IBOutlet weak var btnUI: UIView!
    var settingViewController: UIViewController!
    
    @IBOutlet weak var lblVersion: UILabel!
    
    @IBOutlet weak var lblTitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap_setting:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClickEvent_Setting:")
        btnSetting.addGestureRecognizer(tap_setting)
        
        let tap_ui:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClickEvent_UI:")
        btnUI.addGestureRecognizer(tap_ui)
        
        let tap_logout:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClickEvent_Logout:")
        btnLogout.addGestureRecognizer(tap_logout)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        let infoDictionary = NSBundle.mainBundle().infoDictionary
        
        //_;: AnyObject? = infoDictionary!["CFBundleDisplayName"]
        
        let majorVersion : AnyObject? = infoDictionary! ["CFBundleShortVersionString"]
        
        let minorVersion : AnyObject? = infoDictionary! ["CFBundleVersion"]
        
        
        self.lblVersion.text = "版本号：\(majorVersion!).\(minorVersion!)"        
        self.lblTitle.text = Config.UI.Title
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //self.slideMenuController()?.changeMainViewController(self.nonMenuViewController, close: true)
    
    
    func returnNavView(){
        print("click return button")
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    func onClickEvent_Setting(sender:UITapGestureRecognizer!){
        print("click setting button")
        let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let settingController = storyboard.instantiateViewControllerWithIdentifier("SettingMenuController") as! SettingViewController
        self.settingViewController = UINavigationController(rootViewController: settingController)
        self.slideMenuController()?.changeMainViewController(self.settingViewController, close: true)
    }
    
    func onClickEvent_UI(sender:UITapGestureRecognizer!){
        print("click UI button")
        let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let settingController = storyboard.instantiateViewControllerWithIdentifier("UIImageViewController") as! UIImageViewController
        self.settingViewController = UINavigationController(rootViewController: settingController)
        self.slideMenuController()?.changeMainViewController(self.settingViewController, close: true)
    }
    
    func onClickEvent_Logout(sender:UITapGestureRecognizer!){
        print("click Logout button")
        
        self.slideMenuController()?.closeRight()
        let btn_OK:PKButton = PKButton(title: "登出",
            action: { (messageLabel, items) -> Bool in
                print("=========click==========)")
                //===code here
                Message.shared.logout = true
                exit(0)
                //self.removeAddressFromSystemContact()
                //return true
            },
            fontColor: UIColor(red: 0, green: 0.55, blue: 0.9, alpha: 1.0),
            backgroundColor: nil)
        
        // call alert
        PKNotification.alert(
            title: "退出程序",
            message: "确认退出本程序?",
            items: [btn_OK],
            cancelButtonTitle: "取消",
            tintColor: nil)
        
    }
}
