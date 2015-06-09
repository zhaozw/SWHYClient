import UIKit

class CustomerAddressMenuViewController : UIViewController {
    
   
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var btnSetting: UIView!
    @IBOutlet weak var btnLogout: UIView!
    var settingViewController: UIViewController!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        
        let tap_setting:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClickEvent_Setting:")
        btnSetting.addGestureRecognizer(tap_setting)
        
        let tap_logout:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClickEvent_Logout:")
        btnLogout.addGestureRecognizer(tap_logout)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let infoDictionary = NSBundle.mainBundle().infoDictionary
        
        let appDisplayName: AnyObject? = infoDictionary!["CFBundleDisplayName"]
        
        let majorVersion : AnyObject? = infoDictionary! ["CFBundleShortVersionString"]
        
        let minorVersion : AnyObject? = infoDictionary! ["CFBundleVersion"]
        
        
        self.lblVersion.text = "版本号：\(majorVersion!).\(minorVersion!)"        
        self.lblTitle.text = Config.UI.Title
        
        
        
    }
    
    func onClickEvent_Setting(sender:UITapGestureRecognizer!){
        println("click setting button")
        var storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let settingController = storyboard.instantiateViewControllerWithIdentifier("SettingMenuController") as! SettingViewController
        self.settingViewController = UINavigationController(rootViewController: settingController)
        self.slideMenuController()?.changeMainViewController(self.settingViewController, close: true)
    }
    
    
    func onClickEvent_Logout(sender:UITapGestureRecognizer!){
        println("click Logout button")
        
        self.slideMenuController()?.closeRight()
        let btn_OK:PKButton = PKButton(title: "登出",
            action: { (messageLabel, items) -> Bool in
                println("=========click==========)")
                //===code here
                Message.shared.logout = true
                exit(0)
                //self.removeAddressFromSystemContact()
                return true
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