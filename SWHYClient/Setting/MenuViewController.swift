//
//  MenuViewController.swift
//  SWHYClient
//
//  Created by sunny on 5/14/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//

import Foundation

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
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        let infoDictionary = NSBundle.mainBundle().infoDictionary
        
        let appDisplayName: AnyObject? = infoDictionary!["CFBundleDisplayName"]
        
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
        println("click return button")
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    func onClickEvent_Setting(sender:UITapGestureRecognizer!){
         println("click setting button")
        var storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let settingController = storyboard.instantiateViewControllerWithIdentifier("SettingMenuController") as! SettingViewController
        self.settingViewController = UINavigationController(rootViewController: settingController)
        self.slideMenuController()?.changeMainViewController(self.settingViewController, close: true)
    }
    
    func onClickEvent_UI(sender:UITapGestureRecognizer!){
        println("click UI button")
        var storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let settingController = storyboard.instantiateViewControllerWithIdentifier("UIImageViewController") as! UIImageViewController
        self.settingViewController = UINavigationController(rootViewController: settingController)
        self.slideMenuController()?.changeMainViewController(self.settingViewController, close: true)
    }
    
    }