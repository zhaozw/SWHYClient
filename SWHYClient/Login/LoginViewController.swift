//
//  LoginViewController.swift
//  SWHY_Moblie
//
//  Created by sunny on 3/12/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var btntest: UIButton!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    
    
    
    @IBOutlet weak var chkPassword: AIFlatSwitch!
    @IBOutlet weak var chkOffline: AIFlatSwitch!
    
    @IBOutlet weak var lblOffline: UILabel!
    
    @IBOutlet weak var lblPassword: UILabel!
    
    @IBOutlet weak var imgBG: UIImageView!
    
    
    var request:NSURLRequest = NSURLRequest()
    var failure_auth = 0
    var urlstr:String = ""
    var username:String = ""
    var password:String = ""
    var chkpassword:Bool = false
    
    //override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?){
    //    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
    //}
    
    //convenience override init() {
    //    self.init(nibName: "LoginViewController", bundle: nil)
    //self.init(nibName: "LaunchScreen", bundle: nil)
    
    //}
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName:"LoginViewController", bundle:nil)
    }
    
    
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        btnLogin.addTarget(self, action:"performLogin", forControlEvents: UIControlEvents.TouchUpInside)
        btntest.addTarget(self, action:"performTest", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        //chkPassword.setImage(UIImage(named: "cb_mono_off"), forState: UIControlState.Normal)
        //chkPassword.setImage(UIImage(named: "cb_mono_on"), forState: UIControlState.Selected)
        //chkOffline.setImage(UIImage(named: "cb_mono_off"), forState: UIControlState.Normal)
        //chkOffline.setImage(UIImage(named: "cb_mono_on"), forState: UIControlState.Selected)
        
        //chkPassword.addTarget(self, action: "checkboxClick:", forControlEvents: UIControlEvents.TouchUpInside)
        //chkOffline.addTarget(self, action: "checkboxClick:", forControlEvents: UIControlEvents.TouchUpInside)
        
        //self.addLeftBarButtonWithImage(UIImage(named: "ic_menu_black")!)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let bgindex:Int = NSUserDefaults.standardUserDefaults().integerForKey("UIBackgroundImage")
        var bgimagename:String
        var image:UIImage
        
        println(bgindex)
        
        if bgindex == 5{
            var filePath = Util.applicationFilePath ("uibg_customize", directory: nil)
            image = UIImage(contentsOfFile: filePath)!

        }else{
            image = UIImage(named: "uibg_\(bgindex)")!
        }
        
        imgBG.image = image
        
        //imgBG
        
        let tmpchkpassword: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("ChkPassword")
        chkPassword.selected = (tmpchkpassword as? Bool) ?? false
        let tmpchkoffline: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("ChkOffline")
        chkOffline.selected = (tmpchkoffline as? Bool) ?? false
        
        
        if chkPassword.selected {
            //自动带出用户名和密码
            txtUserName.text = NSUserDefaults.standardUserDefaults().objectForKey("UserName") as? String
            txtPassword.text = NSUserDefaults.standardUserDefaults().objectForKey("Password") as? String
        }
        
    }
    
    @IBAction func onSwitchValueChange(sender: AnyObject) {
        if sender as? AIFlatSwitch == chkOffline {
            println("chkoffline = \(chkOffline.selected)")
        }
    }
    
    func checkboxClick(sender:AnyObject) {
        let tmpsender:AIFlatSwitch = sender as! AIFlatSwitch
        if tmpsender == chkOffline {
            tmpsender.selected = !tmpsender.selected;
            //bigFlatSwitch.setSelected(!bigFlatSwitch.selected, animated: true)
            //smallFlatSwitch.selected = !smallFlatSwitch.selected
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func performTest(){
        
        
        //let data = NSData(contentsOfFile: "/path/to/file/7CHands.dat")!
        
        //let data = NSData(contentsOfURL: <#NSURL#>)
        
        let filepath:String = NSBundle.mainBundle().pathForResource("aa", ofType: "jpg")!
        let data = NSData(contentsOfFile: filepath)!
        
        
        let base64data = data.base64EncodedStringWithOptions(.allZeros)
        
        var data64 = base64data.stringByReplacingOccurrencesOfString("/", withString: "_")
        data64 = data64.stringByReplacingOccurrencesOfString("+", withString: "-")
        
        //dataStr = [dataStr stringByReplacingOccurrencesOfString:@"/"
        //withString:@"_"];
        
        //dataStr = [dataStr stringByReplacingOccurrencesOfString:@"+"
        //withString:@"-"];
        
        //let utf8data = datastr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let utf8datastr = NSString(CString:data64, encoding: NSUTF8StringEncoding)
        //println (utf8datastr)
        //NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
        
        var subject = "标题"
        var subjectutf8 = CFURLCreateStringByAddingPercentEscapes(
            nil,
            subject,
            nil,
            "!*'();:@&=+$,/?%#[]",
            CFStringBuiltInEncodings.UTF8.rawValue
        )
        
        var builder:String = "&DoPostInfo=&AppCreator=admin&Subject=" + (subjectutf8 as! String) + "&SuggestDesc=ss&SuggestDate=2015-04-26&ApplyName=admin&AppDept=npz&AppTel=54656&FileName=aa.jpg&File1=" +  (utf8datastr! as String)
        
        //builder = builder + "&File1=" + utf8str
        
        //[postDic setObject:builder forKey:@"DoPostInfo"];
        //println(builder)
        
        //let url = NSURL(string:"http://notesdev.nipponpaint.com.cn/bunsha/IU/application/IU-LFGSuggestion.nsf/dopostinfo?openagent")
        let urlstr = "http://notesdev.nipponpaint.com.cn/bunsha/IU/application/IU-LFGSuggestion.nsf/dopostinfo?openagent"
        //NetworkEngine.sharedInstance.postRequestWithUrlString(urlstr, postData:builder.dataUsingEncoding(NSUTF8StringEncoding)!)
        NetworkEngine.sharedInstance.postRequestWithUrlString(urlstr, postData:builder,tag:"")
        /*
        let request = NSMutableURLRequest(URL: url!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = builder.dataUsingEncoding(NSUTF8StringEncoding)
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
        data, response, error in
        
        if let httpResponse = response as? NSHTTPURLResponse {
        if httpResponse.statusCode != 200 {
        println("response was not 200: \(response)")
        return
        }
        }
        if (error != nil) {
        println("error submitting request: \(error)")
        return
        }
        
        // handle the data of the successful response here
        }
        task.resume()
        */
    }
    
    
    func performLogin(){
        
        var sim = ""
        if self.txtUserName.text == "" || self.txtPassword.text == ""{
            PKNotification.toast("用户名和密码不能为空")
            return
        }
        
        println(chkOffline.selected)
        
        self.txtUserName.resignFirstResponder()
        self.txtPassword.resignFirstResponder()
        
        if chkOffline.selected == true {
            println("offline checkbox is true")
            performOfflineLogin(self.txtUserName.text,password: self.txtPassword.text)
            return
        }
        
        if UIDevice.currentDevice().model == "iPhone Simulator" {
            println("iphone simulator")
            sim = "89860064090506059492"   //36F75479-6635-410C-AA27-D3385726432D
        }else{
            println(" iphone device ")
            //sim = UIDevice.currentDevice().identifierForVendor.UUIDString
            sim = "89860064090506059492"
        }
        
        username  = self.txtUserName.text
        password = self.txtPassword.text
        
        Message.shared.postUserName = username
        Message.shared.postPassword = password
        
        println(username)
        println(password)
        
        //username = "shenyd"
        //password = "east"
        //NSUserDefaults.standardUserDefaults().setObject(txtUserName.text, forKey: "UserName") 
        //NSUserDefaults.standardUserDefaults().setObject(txtPassword.text, forKey: "Password")
        
        
        
        let url = Config.URL.Login + "&user="+username+"&sim=" + sim
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "HandleNetworkResult:", name: Config.RequestTag.DoLogin, object: nil)
        NetworkEngine.sharedInstance.addRequestWithUrlString(url, tag: Config.RequestTag.DoLogin, useCache: false)
        //NetworkEngine.sharedInstance.addRequestWithUrlString(url, tag: Config.RequestTag.DoLogin, useCache: false)
        PKNotification.toast("登录中")
        //self.view.makeToast(message: "登录中...")
        
    }
    
    func performOfflineLogin(username:String,password:String){
        
        var tmpusername = NSUserDefaults.standardUserDefaults().objectForKey("UserName") as? String
        var tmppassword = NSUserDefaults.standardUserDefaults().objectForKey("Password") as? String
        
        if (tmpusername == username && tmppassword == password) {
            PKNotification.toast("离线登陆成功")
            NSUserDefaults.standardUserDefaults().setObject(chkPassword.selected, forKey: "ChkPassword")
            NSUserDefaults.standardUserDefaults().setObject(chkOffline.selected, forKey: "ChkOffline")
            NSUserDefaults.standardUserDefaults().synchronize()
            //临时模拟离线登陆
            //let mainViewController:MainViewController = MainViewController()
            //let nvc=UINavigationController(rootViewController:mainViewController);
            
            //window
            Message.shared.loginType = "Offline"
            println("-----Offline-------")
            
            //记录模块访问日志
            let accessLogItem = AccessLogItem()
            accessLogItem.userid = NSUserDefaults.standardUserDefaults().objectForKey("UserName") as! String
            accessLogItem.online = Message.shared.loginType == "Online" ? "true" : "false"
            accessLogItem.moduleid = ""
            accessLogItem.time = Util.getCurDateString()
            accessLogItem.type = "Login"
            accessLogItem.modulename = "登陆"
            
            DBAdapter.shared.syncAccessLogItem(accessLogItem)
            
            //UIApplication.sharedApplication().keyWindow?.rootViewController = nvc
            
            self.gotoview()
            
        } else {
            PKNotification.toast("离线登陆失败")
        }
        
    }
    func HandleNetworkResult(notify:NSNotification)
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Config.RequestTag.DoLogin, object: nil)
        // println(notify.valueForKey("object")?.valueForKey("Flag"))
        
        let result:Result = notify.valueForKey("object") as! Result
        if result.status == "Error" {
            PKNotification.toast(result.message)
        }else if result.status=="OK"{
            let tmp:String = result.userinfo.valueForKey("Flag") as! String
            let message:String = result.userinfo.valueForKey("Message") as! String
            PKNotification.toast(message)
            if tmp == "True" {
                
                NSUserDefaults.standardUserDefaults().setObject(username, forKey: "UserName") 
                NSUserDefaults.standardUserDefaults().setObject(password, forKey: "Password")
                NSUserDefaults.standardUserDefaults().setObject(chkPassword.selected, forKey: "ChkPassword")
                NSUserDefaults.standardUserDefaults().setObject(chkOffline.selected, forKey: "ChkOffline")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                //window
                Message.shared.loginType = "Online"
                println("-----Online------")
                
                
                //记录模块访问日志
                let accessLogItem = AccessLogItem()
                accessLogItem.userid = NSUserDefaults.standardUserDefaults().objectForKey("UserName") as! String
                accessLogItem.online = Message.shared.loginType == "Online" ? "true" : "false"
                accessLogItem.moduleid = ""
                accessLogItem.time = Util.getCurDateString()
                accessLogItem.type = "Login"
                accessLogItem.modulename = "登陆"
                
                DBAdapter.shared.syncAccessLogItem(accessLogItem)
                
                self.gotoview()
                /*
                //UIApplication.sharedApplication().keyWindow?.rootViewController = nvc
                let mainViewController:MainViewController = MainViewController()
                let nvc=UINavigationController(rootViewController:mainViewController);
                
                var storyboard = UIStoryboard(name: "Setting", bundle: nil)
                let rightViewController = storyboard.instantiateViewControllerWithIdentifier("MenuViewController") as MenuViewController
                
                let slideMenuController = SlideMenuController(mainViewController: nvc, rightMenuViewController: rightViewController)
                UIApplication.sharedApplication().keyWindow?.rootViewController = slideMenuController
                */
                
                //
                //self.navigationController?.pushViewController(mainViewController, animated: true)
            }
            
        }
        
    }
    func gotoview(){
        //UIApplication.sharedApplication().keyWindow?.rootViewController = nvc
        let mainViewController:MainViewController = MainViewController()
        let nvc=UINavigationController(rootViewController:mainViewController);
        
        var storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let rightViewController = storyboard.instantiateViewControllerWithIdentifier("MenuViewController") as! MenuViewController
        
        let slideMenuController = SlideMenuController(mainViewController: nvc, rightMenuViewController: rightViewController)
        UIApplication.sharedApplication().keyWindow?.rootViewController = slideMenuController
        
    }
}
