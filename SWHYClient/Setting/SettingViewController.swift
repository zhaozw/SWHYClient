//
//  SettingViewController.swift
//  SWHYClient
//
//  Created by sunny on 5/15/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblVersion: UILabel!
   
    @IBOutlet weak var swh_password: UISwitch!
    
    @IBOutlet weak var swh_offline: UISwitch!

    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        swh_password.addTarget(self, action: Selector("stateChanged_password:"), forControlEvents: UIControlEvents.ValueChanged)
        swh_offline.addTarget(self, action: Selector("stateChanged_offline:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        /*
        var navbar = self.navigationController?.navigationBar
        println(self.navigationController?.navigationBar.frame.origin.y)
        println(self.navigationController?.navigationBar.frame.height)
        var y = self.navigationController?.navigationBar.frame.origin.y 
        var h = self.navigationController?.navigationBar.frame.height
        var s = y! + h!
        //println(self.contentView.frame.origin.y)
        //self.contentView.frame.origin.y = 500
        //println(self.contentView.frame.origin.y)
        */
        
        self.title = "设置"
                
        let infoDictionary = NSBundle.mainBundle().infoDictionary
        
        let appDisplayName: AnyObject? = infoDictionary!["CFBundleDisplayName"]
        
        let majorVersion : AnyObject? = infoDictionary! ["CFBundleShortVersionString"]
        
        let minorVersion : AnyObject? = infoDictionary! ["CFBundleVersion"]
        
        
        self.lblVersion.text = "版本号：\(majorVersion!).\(minorVersion!)"        
        self.lblTitle.text = Config.UI.Title
        
        
        let backitem = UIBarButtonItem(title: Config.UI.PreNavItem, style: UIBarButtonItemStyle.Plain, target: self, action: "returnNavView")
        self.navigationItem.leftBarButtonItem = backitem
        self.setNavigationBarItem()
        
        let tmpchkpassword: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("ChkPassword")
        print("-----------!!!!!!!!!!!!!!!!!!!!!\(tmpchkpassword)")
        //swh_password.selected = (tmpchkpassword as? Bool) ?? false
        swh_password.setOn((tmpchkpassword as? Bool) ?? false, animated: true)
        let tmpchkoffline: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("ChkOffline")
        print("====================+++++++++++++++\(tmpchkoffline)")
        //swh_offline.selected = (tmpchkoffline as? Bool) ?? false
        swh_offline.setOn((tmpchkoffline as? Bool) ?? false, animated: true)
        
    }
    
    func returnNavView(){
        print("click return button")
        
        let mainViewController:MainViewController = MainViewController()
        let nvc=UINavigationController(rootViewController:mainViewController);
        
        let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let rightViewController = storyboard.instantiateViewControllerWithIdentifier("MenuViewController") as! MenuViewController
        
        let slideMenuController = SlideMenuController(mainViewController: nvc, rightMenuViewController: rightViewController)
        //self.window?.rootViewController = slideMenuController
        UIApplication.sharedApplication().keyWindow?.rootViewController = slideMenuController
        
        
    }
    
    func stateChanged_password(switchState: UISwitch) {
        NSUserDefaults.standardUserDefaults().setObject(swh_password.on, forKey: "ChkPassword")
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    func stateChanged_offline(switchState: UISwitch) {
        NSUserDefaults.standardUserDefaults().setObject(swh_offline.on, forKey: "ChkOffline")
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
}