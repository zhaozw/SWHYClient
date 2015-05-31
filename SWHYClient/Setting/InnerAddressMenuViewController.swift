import UIKit

class InnerAddressMenuViewController : UIViewController {
    
    @IBOutlet weak var btnCopytoAddressbook: UIView!
    @IBOutlet weak var btnRemoveFromAddressbook: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblVersion: UILabel!
       
    @IBOutlet weak var btnSetting: UIView!
    var settingViewController: UIViewController!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let tap_copytoaddress:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClick_CopytoAddress:")
        btnCopytoAddressbook.addGestureRecognizer(tap_copytoaddress)
        
        let tap_removefromaddress:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClick_RemoveFromAddress:")
        btnRemoveFromAddressbook.addGestureRecognizer(tap_removefromaddress)
        
        let tap_setting:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClickEvent_Setting:")
        btnSetting.addGestureRecognizer(tap_setting)
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
    
    func onClick_CopytoAddress(sender:UITapGestureRecognizer!){
        
        //self.slideMenuController()?.hidesBottomBarWhenPushed
        self.slideMenuController()?.closeRight()
        println("click")
        let btn_OK:PKButton = PKButton(title: "确认",
            action: { (messageLabel, items) -> Bool in
                println("=========click==========)")
                //===code here
                self.syncAddressToSystemContact()
                return true
            },
            fontColor: UIColor(red: 0, green: 0.55, blue: 0.9, alpha: 1.0),
            backgroundColor: nil)
        
        // call alert
        PKNotification.alert(
            title: "操作确认",
            message: "确认将所内通讯录同步至手机通讯录中?",
            items: [btn_OK],
            cancelButtonTitle: "取消",
            tintColor: nil)
        
    }
    
    func onClick_RemoveFromAddress(sender:UITapGestureRecognizer!){
        
        //self.slideMenuController()?.hidesBottomBarWhenPushed
        self.slideMenuController()?.closeRight()
        println("click")
        let btn_OK:PKButton = PKButton(title: "确认",
            action: { (messageLabel, items) -> Bool in
                println("=========click==========)")
                //===code here
                
                self.removeAddressFromSystemContact()
                return true
            },
            fontColor: UIColor(red: 0, green: 0.55, blue: 0.9, alpha: 1.0),
            backgroundColor: nil)
        
        // call alert
        PKNotification.alert(
            title: "操作确认",
            message: "确认删除系统通讯录中的同步拷贝?",
            items: [btn_OK],
            cancelButtonTitle: "取消",
            tintColor: nil)
        
    }
    
    
    func syncAddressToSystemContact(){
       
        let contacthelper = ContactsHelper()
        
        if let itemlist:AnyObject = DBAdapter.shared.queryInnerAddressList("'1'=?", paralist: ["1"]) {
            
            //self.itemlist = data as [InnerAddressItem]
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "HandleResult:", name: Config.NotifyTag.RevokeSyncAddressbook, object: nil)
            
            println("-----------remove start at --\(Util.getCurDateString())")
            contacthelper.removeAllFromAddressBookByGroupName(Config.AddressBook.SyncAddressBookGroupName)
            println("-----------remove end at --\(Util.getCurDateString())")
            
            println("-----------sync start at --\(Util.getCurDateString())")
            contacthelper.syncToAddressBook(itemlist as! [InnerAddressItem])
            println("-----------sync end at --\(Util.getCurDateString())")
        }
        
        /*
        person.firstName = "yonghua"
        person.lastName = "lu"
        person.jobTitle = "engineer"
        person.phoneNumber = "123456789"
        contacthelper.addToAddressBook(person)
        */
    
    }
    
    func removeAddressFromSystemContact(){
        
        let contacthelper = ContactsHelper()
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "HandleResult:", name: Config.NotifyTag.RevokeRemoveAddressbook, object: nil)
        println("-----------remove start at --\(Util.getCurDateString())")
        contacthelper.removeAllFromAddressBookByGroupName(Config.AddressBook.SyncAddressBookGroupName)
        println("-----------remove end at --\(Util.getCurDateString())")
       
        
    }
    
    func HandleResult(notify:NSNotification)
    {
        println("拷贝所内通讯录完成")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: notify.name, object: nil)
        
        let result:Result = notify.valueForKey("object") as! Result
        PKNotification.toast(result.message)
        
    }
    
    func onClickEvent_Setting(sender:UITapGestureRecognizer!){
        println("click setting button")
        var storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let settingController = storyboard.instantiateViewControllerWithIdentifier("SettingMenuController") as! SettingViewController
        self.settingViewController = UINavigationController(rootViewController: settingController)
        self.slideMenuController()?.changeMainViewController(self.settingViewController, close: true)
    }
    
}