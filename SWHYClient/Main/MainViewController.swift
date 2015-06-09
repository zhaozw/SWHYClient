//
//  ViewController.swift
//  SWHY_Moblie
//
//  Created by sunny on 3/9/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//

import UIKit
//import Cartography

class MainViewController: UIViewController{
    @IBOutlet var scrollview: UIScrollView!
    //var arrData:NSArray!
    var arrMutiData:NSMutableArray!
    
    let col:CGFloat = 3
    let viewW:CGFloat = 85
    let viewH:CGFloat = 110
    var margin:CGFloat = 0  //margin 在viewDidLoad 中计算
    let marginH:CGFloat = 20
    let marginTop:CGFloat = 30
    
    var fillViewFromSql = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?){
        super.init(nibName: "MainViewController", bundle: nil)
        
    }
    
    
    
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Config.UI.Title
        self.scrollview.scrollEnabled = true
        println("---view did load ------\(Message.shared.loginType)----")
        self.scrollview.frame.origin.x = 0
        self.scrollview.frame.origin.y = 0 //20
        
        self.margin = (Util.getScreen().width - col*viewW) / (col+1)

        //用于更新后台SQL及缓存
        if Message.shared.loginType == "Online"{
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "HandleNetworkResult:", name: Config.RequestTag.GetMainMenu, object: nil)
            NetworkEngine.sharedInstance.addRequestWithUrlString(Config.URL.MainMenuList, tag: Config.RequestTag.GetMainMenu,useCache:false)
            //从SQL里取得表信息并加载
            if let data:NSMutableArray = DBAdapter.shared.queryMainMenuList("'1'=?", paralist: ["1"]) {
                self.fillViewFromSql = true
                self.arrMutiData = data
                println("======================load view from sql=================")
                loadView(self.arrMutiData)
            }
            //登陆成功后，上传日志
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "HandleNetworkResult:", name: Config.RequestTag.PostAccessLog, object: nil)
            NetworkEngine.sharedInstance.postLogList(Config.URL.PostAccessLog, tag: Config.RequestTag.PostAccessLog)
            
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "HandleNetworkResult:", name: Config.RequestTag.PostCustomerLog, object: nil)
            NetworkEngine.sharedInstance.postCustomerLogList(Config.URL.PostCustomerLog, tag: Config.RequestTag.PostCustomerLog)
            
            //Loger.shared.uploadAccessLogList()
        }
        else{
            //从SQL里取得表信息并加载
            if let data:NSMutableArray = DBAdapter.shared.queryMainMenuList("offline=?", paralist:["Yes"]) {
                self.fillViewFromSql = true
                self.arrMutiData = data
                println("======================load view from sql=================")
                loadView(self.arrMutiData)
            }
        }
        
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        //
        //self.navigationController?.setNavigationBarHidden(false, animated: false)
        //self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "default_ios_2"), forBarMetrics:UIBarMetrics.Default)
        var storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let rightViewController = storyboard.instantiateViewControllerWithIdentifier("MenuViewController") as! MenuViewController
        self.slideMenuController()?.changeRightViewController(rightViewController, closeRight: true)
        self.setNavigationBarItem()
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        
        
    }
    override func prefersStatusBarHidden() -> Bool {
        //是否隐藏status bar
        return false
    }
    func HandleNetworkResult(notify:NSNotification)
    {
        let result:Result = notify.valueForKey("object") as! Result
        NSNotificationCenter.defaultCenter().removeObserver(self, name: result.tag, object: nil)
        if result.status == "Error" {
            PKNotification.toast(result.message)
        }else if result.status=="OK"{
            if result.tag == Config.RequestTag.GetMainMenu {
                self.arrMutiData = result.userinfo as! NSMutableArray
                
                //if self.fillViewFromSql == false {
                //如果还未从SQL里加载视图，则加载
                //PKNotification.toast("----加载模块清单-----")
                loadView(self.arrMutiData)
                //}
                //将最新模块信息更新至sqlite
                println("------Update MainMenuList to SQLite--------")
                DBAdapter.shared.syncMainMenuList(self.arrMutiData)
            }
            else if result.tag == Config.RequestTag.PostAccessLog || result.tag == Config.RequestTag.PostCustomerLog {
                println("--+++----Update SQLite AccessLog to already sync--------\(result.message)")
                PKNotification.toast(result.message)
            }
        }
        
    }
    
    func HandleNetworkResult_Loger(notify:NSNotification)
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Config.RequestTag.PostAccessLog, object: nil)
        
        let result:Result = notify.valueForKey("object") as! Result
        
        if result.status.componentsSeparatedByString("Error").count > 1 {
            println("-------post log error-------------")
            PKNotification.toast(result.message)
        }else if result.status=="OK"{
            println("------Update SQLite AccessLog to already sync--------\(result.message)")
            PKNotification.toast("result.message")
            
        }
        
    }
    
    func loadView(arrMutiData:NSMutableArray){
        var sviewY:CGFloat=0.00
        self.scrollview.subviews.map({
            $0.removeFromSuperview()
        })
        for var i:Int=0;i<self.arrMutiData.count; i++ {
            
            let arrobj:MainMenuItemBO = self.arrMutiData[i] as! MainMenuItemBO
            
            var bundle:NSBundle = NSBundle.mainBundle()
            let uiViewArray:NSArray = bundle.loadNibNamed("MainMenuItem", owner: nil, options: nil)
            let uiView = uiViewArray.lastObject as! MainMenuItem
            
            let viewX:CGFloat = self.margin + (viewW+self.margin) * (CGFloat(i)%col)
            let viewY:CGFloat = marginTop + (viewH+marginH) * CGFloat(i/Int(col))
            
            uiView.frame = CGRectMake(viewX,viewY,viewW, viewH)
            
            uiView.FillMenu(arrobj)
            uiView.userInteractionEnabled = true
            
            
            //uiView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "doGoToView:"))
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "doGoToView:")
            //tap.numberOfTapsRequired = 1
            //tap.numberOfTouchesRequired = 1
            uiView.addGestureRecognizer(tap)
            tap.view?.tag = i
            //simulation code - here i need pass the object clicked
            //tap.AssociatedObject = schedulle
            
            self.scrollview.addSubview(uiView)
            sviewY = viewY+200.00
            
        }
        self.scrollview.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, sviewY)
        
    }
    
    func doGoToView(sender:UITapGestureRecognizer!){
        
        let i = (sender.view?.tag)
        
        let arrobj:MainMenuItemBO = self.arrMutiData[i!] as! MainMenuItemBO
        
        if arrobj.classname != nil {
            if arrobj.classname != "" {
                let aClass = NSClassFromString(arrobj.classname) as! UIViewController.Type
                let aObject = aClass() as UIViewController
                Message.shared.curMenuItem = arrobj
                //记录模块访问日志
                let accessLogItem = AccessLogItem()
                accessLogItem.userid = NSUserDefaults.standardUserDefaults().objectForKey("UserName") as! String
                accessLogItem.online = Message.shared.loginType == "Online" ? "true" : "false"
                accessLogItem.moduleid = arrobj.id
                accessLogItem.time = Util.getCurDateString()
                accessLogItem.type = "OpenModule"
                accessLogItem.modulename = arrobj.name
                
                DBAdapter.shared.syncAccessLogItem(accessLogItem)
                
                //aObject.title = arrobj.name
                self.navigationController?.pushViewController(aObject,animated:false);
            }}
    }
    
    func getData()->NSArray{
        
        
        var bundle:NSBundle = NSBundle.mainBundle()
        var path:String = bundle.pathForResource("app", ofType: "plist")!
        return NSArray(contentsOfFile: path)!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

