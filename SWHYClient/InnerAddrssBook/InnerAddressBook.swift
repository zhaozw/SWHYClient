//
//  InnerAddressBook.swift
//  SWHYClient
//
//  Created by sunny on 3/24/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//

import UIKit
@objc(InnerAddressBook) class InnerAddressBook: UITableViewController,UISearchBarDelegate, UISearchDisplayDelegate,InnerAddressBookHeaderDelegate {

//@objc(InnerAddressBook) class InnerAddressBook: UITableViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate, UISearchDisplayDelegate,InnerAddressBookHeaderDelegate {
    //@IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    var itemlist = [InnerAddressItem]()
    var deptlist = [InnerAddressDeptItem]()
    var filteredItemList = [InnerAddressItem]()
    var sectionInfoArray: NSMutableArray! = NSMutableArray()
    var getaddress = false
    var getdept = false
    var preopenindex = NSNotFound  //上次打开的setion
    var opensectionindex = NSNotFound
    
    var fillViewFromSql = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    convenience init() {
        self.init(nibName: "InnerAddressBook", bundle: nil)
        //self.init(nibName: "LaunchScreen", bundle: nil)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        searchBar.setShowsCancelButton(true, animated: true)
        
        //var searchBarTextField : UITextField? = nil
        for mainview in searchBar.subviews
        {
            for subview in mainview.subviews {
                if subview.isKindOfClass(UIButton)
                {
                    let cancelbutton = subview as? UIButton
                    cancelbutton?.setTitle("取消", forState: UIControlState.Normal)
                    break
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.title = Message.shared.curMenuItem.name
        opensectionindex = NSNotFound
        getaddress = false
        getdept = false
        
        if Message.shared.loginType == "Online" {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "HandleNetworkResult:", name: Config.RequestTag.GetInnerAddressBook, object: nil)
            NetworkEngine.sharedInstance.addRequestWithUrlString(Config.URL.InnerAddressBook, tag: Config.RequestTag.GetInnerAddressBook,useCache:false)
            
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "HandleNetworkResult:", name: Config.RequestTag.GetInnerAddressBook_Dept, object: nil)
            NetworkEngine.sharedInstance.addRequestWithUrlString(Config.URL.InnerAddressBook_Dept, tag: Config.RequestTag.GetInnerAddressBook_Dept,useCache:false)
        }
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        //println(self.navigationController?.navigationBar.frame.origin.y)
        //println(self.navigationController?.navigationBar.frame.height)
        //self.tableView.frame.origin.y = 64
        //println(self.tableView.frame.origin.y)
        //self.tableView.backgroundColor = UIColor.redColor()
        
        //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        let nib = UINib(nibName:"InnerAddressBookCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "Cell")
        self.searchDisplayController?.searchResultsTableView.registerNib(nib, forCellReuseIdentifier: "Cell")
        //self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        let nib2 = UINib(nibName:"InnerAddressBookHeader", bundle: nil)
        self.tableView.registerNib(nib2, forHeaderFooterViewReuseIdentifier: "Header")
        
        
        // Do any additional setup after loading the view.
        
        //从SQL里取得表信息并加载
        if let data:AnyObject = DBAdapter.shared.queryInnerAddressList("'1'=?", paralist: ["1"]) {
            //self.fillViewFromSql = true
            self.itemlist = data as! [InnerAddressItem]
            self.getaddress = true
        }
        if let deptdata:AnyObject = DBAdapter.shared.queryInnerAddressDeptList("'1'=?", paralist: ["1"]) {
            //self.fillViewFromSql = true
            self.deptlist = deptdata as! [InnerAddressDeptItem]
            self.getdept = true
            
        }
        print("get SQL表信息 部门个数 \(self.deptlist.count) , SQL 人员个数 \(self.itemlist.count)")
        if self.getaddress == true && self.getdept == true {
            //此处加载视图  已经获得所有通讯录和部门信息
            //print("======================load view from sql=================")
            self.fillViewFromSql = true
            ComputeAddressInfo()
        }else{
            if Message.shared.loginType != "Online" {
                //print("=====所内通讯录未初始化")
                PKNotification.toast("所内通讯录还未首次在线访问，无法提供离线数据！")
            }
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let backitem = UIBarButtonItem(title: Config.UI.PreNavItem, style: UIBarButtonItemStyle.Plain, target: self, action: "returnNavView")
        self.navigationItem.leftBarButtonItem = backitem
        
        let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let innerAddressViewController = storyboard.instantiateViewControllerWithIdentifier("InnerAddresMenuViewController") as! InnerAddressMenuViewController
        self.slideMenuController()?.changeRightViewController(innerAddressViewController, closeRight: true)
        self.setNavigationBarItem()
    }
    
    func returnNavView(){
        //print("click return button")
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    func HandleNetworkResult(notify:NSNotification)
    {
        //print("取得在线数据")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: notify.name, object: nil)
        
        let result:Result = notify.valueForKey("object") as! Result
        if result.status == "Error" {
            PKNotification.toast(result.message)
        }else if result.status=="OK"{
            //println ("++++get+++++\(notify.name)")
            if notify.name == Config.RequestTag.GetInnerAddressBook {
                self.itemlist = result.userinfo as! [InnerAddressItem]
                self.getaddress = true
                DBAdapter.shared.syncInnerAddressList(self.itemlist)
            }else if notify.name == Config.RequestTag.GetInnerAddressBook_Dept{
                //print("开始获取在线部门数")
                self.deptlist = result.userinfo as! [InnerAddressDeptItem]
                self.getdept = true
                DBAdapter.shared.syncInnerAddressDeptList(self.deptlist)
                //print("get 在线表信息 部门个数 \(self.deptlist.count) ")
            }
            if self.fillViewFromSql == false {
                if self.getaddress == true && self.getdept == true {
                    //此处加载视图  已经获得所有通讯录和部门信息
                    
                    ComputeAddressInfo()
                }
            }
        }
    }
    
    
    
    func ComputeAddressInfo() {
        var addressInfoList: NSMutableArray?
        
        // 定位到plist文件并将文件拷贝到数组中存放
        //var fileUrl = NSBundle.mainBundle().URLForResource("FriendInfo", withExtension: "plist")
        //var GroupDictionariesArray = NSArray(contentsOfURL: fileUrl!)
        addressInfoList = NSMutableArray(capacity: self.deptlist.count)
        
        // 遍历数组，根据组和单元格的结构分别赋值
        /*
        for dept in self.deptlist! {
        var deptitem: InnerAddressDeptItem = InnerAddressDeptItem()
        deptitem.name = GroupDictionary["GroupName"] as String
        
        var friendDictionaries: NSArray = GroupDictionary["Friends"] as NSArray
        var friends = NSMutableArray(capacity: friendDictionaries.count)
        
        for friendDictionary in friendDictionaries {
        var friendAsDic: NSDictionary = friendDictionary as NSDictionary
        var friend: Friend = Friend()
        
        friend.setValuesForKeysWithDictionary(friendAsDic)
        friends.addObject(friend)
        }
        group.friends = friends
        addressInfoList!.addObject(group)
        }
        */
        
        for item in self.itemlist{
            for dept in self.deptlist{
                
                if dept.name == item.dept {
                    dept.addresslist.append(item)
                }
                
            }
            
            
        }
        
        //return self.deptlist!
        
        
        // 检查SectionInfoArray是否已被创建，如果已被创建，则检查组的数量是否匹配当前实际组的数量。通常情况下，您需要保持SectionInfo与组、单元格信息保持同步。如果扩展功能以让用户能够在表视图中编辑信息，那么需要在编辑操作中适当更新SectionInfo
        //print("reload data=================")
        if self.sectionInfoArray == nil || self.sectionInfoArray.count != self.numberOfSectionsInTableView(self.tableView) {
            // 对于每个用户组来说，需要为每个单元格设立一个一致的SectionInfo对象
            let infoArray: NSMutableArray = NSMutableArray()
            
            for dept in self.deptlist {
                //var dictionary: NSArray = (dept as InnerAddressDeptItem).addresslist
                let sectionInfo = SectionInfo()
                sectionInfo.dept = dept as InnerAddressDeptItem
                sectionInfo.headerView.HeaderOpen = false
                
                infoArray.addObject(sectionInfo)
            }
            self.sectionInfoArray = infoArray
            self.tableView.reloadData()
        }
        
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if tableView == self.searchDisplayController?.searchResultsTableView {
            return 1
            
        } else {
            return self.deptlist.count
        }
        
    }
    
    // UITableViewDataSource Functions
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.itemlist.count
        //println("---start numberOfRowsInSection section----\(sectionInfoArray.count)--\(section)")
        if tableView == self.searchDisplayController?.searchResultsTableView {
            //println("rows in section search bar")
            return self.filteredItemList.count
            
        } else {
            //println("rows in section normal ")
            
            let sectionInfo: SectionInfo = self.sectionInfoArray[section] as! SectionInfo
            let numStoriesInSection = sectionInfo.dept.addresslist.count
            //var sectionOpen = sectionInfo.headerView.HeaderOpen
            
            //println("---numberOfRowsInSection isopen\(sectionOpen) section:\(section)---count:\(numStoriesInSection)-  openindex\(opensectionindex)")
            
            return section == opensectionindex ? numStoriesInSection : 0
            
            //return sectionOpen ? numStoriesInSection : 0
            
            //return self.itemlist.count
            
        }
    }
    
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 在tableview中查询一个条目，如果没有创建一个。
        
        //let FriendCellIdentifier = "FriendCellIdentifier"
        //var cell: FriendCell = tableView.dequeueReusableCellWithIdentifier(FriendCellIdentifier) as FriendCell
        
        
        
        //var cell:InnerAddressBookCell! = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? InnerAddressBookCell
        
        // 从我们的糖果数组中获得相应的内容
        var item:InnerAddressItem
        
        if tableView == self.searchDisplayController?.searchResultsTableView {
            //println("cell for search")
            
            item = filteredItemList[indexPath.row]
            
        } else {
            
            //println("cell for  normal")
            //item = self.itemlist[indexPath.row] as InnerAddressItem
            //println("---start cellForRowAtIndexPath section---\(indexPath.section)/\(sectionInfoArray.count)")
            
            let dept: InnerAddressDeptItem = (self.sectionInfoArray[indexPath.section] as! SectionInfo).dept
            //println("---\(indexPath.row)/\(dept.addresslist.count)---")
            item = dept.addresslist[indexPath.row] as InnerAddressItem
            //cell.setFriend(cell.friend)
            
            
        }
        let cell:InnerAddressBookCell! = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? InnerAddressBookCell
        
        //cell.textLabel?.text = item.name
        cell.dept.text = item.dept
        cell.name.text = item.name
        cell.icon?.image = UIImage(named: "contactbook")
        cell.telcom_s.text = item.mobiletelecom1
        cell.mobile_s.text = item.mobile1
        cell.btntelcom.setTitle(item.mobiletelecom, forState:UIControlState.Normal)
        cell.btnmobile.setTitle(item.mobile, forState:UIControlState.Normal)
        
        //点击事件
        cell.btntelcom.addTarget(self, action: "onClick_Call:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.btnmobile.addTarget(self, action: "onClick_Call:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        //println("---end cellForRowAtIndexPath section----")
        return cell
        
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // 返回指定的section header视图
        //println("---start tableview section----")
        //var tempcell:InnerAddressBookHeader = tableView.dequeueReusableHeaderFooterViewWithIdentifier("Header")
        //println(tempcell)
        let sectionHeaderView:InnerAddressBookHeader = tableView.dequeueReusableHeaderFooterViewWithIdentifier("Header") as! InnerAddressBookHeader
        
        //var temp:CGRect = sectionHeaderView.contentView.frame
        //temp.size.width = CGFloat(450)
        //sectionHeaderView.contentView.frame = temp
        
        let sectionInfo: SectionInfo = self.sectionInfoArray[section] as! SectionInfo
        //sectionHeaderView.frame.height = CGFloat(45)
        
        sectionInfo.headerView = sectionHeaderView
        sectionHeaderView.LblTitle.text = sectionInfo.dept.name
        sectionHeaderView.section = section
        sectionHeaderView.delegate = self
        //println("---end tableview section----")
        return sectionHeaderView
    }
    
    func onClick_Call(sender:UIButton) {
        let num = sender.titleLabel?.text
        if num != nil {
            
            
            
            
            let btn_OK:PKButton = PKButton(title: "拨打",
                action: { (messageLabel, items) -> Bool in
                    let urlstr = "tel://\(num!)"
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
                message: "确认拨打电话:\(num!)?",
                items: [btn_OK],
                cancelButtonTitle: "取消",
                tintColor: nil)
            }
    }
    
    func filterContentForSearchText(searchText: String) {
        
        // 使用过滤方法过滤数组 陈陈
        //print("filter content \(searchText)")
        self.filteredItemList = self.itemlist.filter({( innerAddressItem: InnerAddressItem) -> Bool in
            
            //let categoryMatch = (scope == "All") || (innerAddressItem.dept == scope)
            let stringMatch = innerAddressItem.query.rangeOfString(searchText)
            
            //return categoryMatch && (stringMatch != nil)
            return (stringMatch != nil)
            
        })
        
    }
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String?) -> Bool {
        
        print(searchString)
        self.filterContentForSearchText(searchString!)
        
        return true
        
    }
    
    
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        
        self.filterContentForSearchText(self.searchDisplayController!.searchBar.text!)
        
        return true
        
    }
    
    /*
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    self.performSegueWithIdentifier("Detail", sender: tableView)
    
    }
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        print("did select row at index path =\(indexPath)")
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var item:InnerAddressItem
        
        if tableView == self.searchDisplayController?.searchResultsTableView {
            item = self.filteredItemList[indexPath.row] as InnerAddressItem
            
            
        } else {
            
            let dept: InnerAddressDeptItem = (self.sectionInfoArray[indexPath.section] as! SectionInfo).dept
            //println("---\(indexPath.row)/\(dept.addresslist.count)---")
            item = dept.addresslist[indexPath.row] as InnerAddressItem
            
        }
        
        
        let nextController:InnerAddressDetail = InnerAddressDetail()
        Message.shared.curInnerAddressItem = item
        self.navigationController?.pushViewController(nextController,animated:false);
        
        
        
        //println("performSegueWithIdentifier")
        //self.performSegueWithIdentifier("Detail", sender: tableView)
        
    } 
    /*
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //return CGFloat(DefaultRowHeight)
    //println("Default row height\(DefaultRowHeight)")
    return CGFloat(45)
    }
    */
    
    func innerAddressBookHeader(innerAddressBookHeader: InnerAddressBookHeader, sectionOpened: Int) {
        //println("++++++section open+++++++++\(sectionOpened)")
        let sectionInfo: SectionInfo = self.sectionInfoArray[sectionOpened] as! SectionInfo
        sectionInfo.headerView.HeaderOpen = true
        
        if self.preopenindex != NSNotFound{
            let preSectionInfo: SectionInfo = self.sectionInfoArray[preopenindex] as! SectionInfo
            preSectionInfo.headerView.ImgNarrow.image = UIImage(named:"narrow_right")
        }
        sectionInfo.headerView.ImgNarrow.image = UIImage(named:"narrow_down")
        
        
        //创建一个包含单元格索引路径的数组来实现插入单元格的操作：这些路径对应当前节的每个单元格
        let countOfRowsToInsert = sectionInfo.dept.addresslist.count
        //var indexPathsToInsert = NSMutableArray()
        var indexPathsToInsert:[NSIndexPath]=[]
        for (var i = 0; i < countOfRowsToInsert; i++) {
            //indexPathsToInsert.addObject(NSIndexPath(forRow: i, inSection: sectionOpened))
            indexPathsToInsert.append(NSIndexPath(forRow: i, inSection: sectionOpened))
        }
        
        // 创建一个包含单元格索引路径的数组来实现删除单元格的操作：这些路径对应之前打开的节的单元格
        //var indexPathsToDelete = NSMutableArray()
        var indexPathsToDelete:[NSIndexPath] = []
        let previousOpenSectionIndex = opensectionindex
        //var perviousOpenSectionIndex = preopenindex
        //println("本次打开的section\(sectionOpened)  上次打开的section\(opensectionindex)")
        if previousOpenSectionIndex != NSNotFound {
            let previousOpenSection: SectionInfo = self.sectionInfoArray[previousOpenSectionIndex] as! SectionInfo
            //println("will close \(previousOpenSectionIndex)")
            previousOpenSection.headerView.HeaderOpen = false
            previousOpenSection.headerView.toggleOpen(false)
            //previousOpenSection.headerView.toggleOpen(true)
            
            let countOfRowsToDelete = previousOpenSection.dept.addresslist.count
            for (var i = 0; i < countOfRowsToDelete; i++) {
                //indexPathsToDelete.addObject(NSIndexPath(forRow: i, inSection: previousOpenSectionIndex))
                indexPathsToDelete.append(NSIndexPath(forRow: i, inSection: previousOpenSectionIndex))
            }
        }
        
        // 设计动画，以便让表格的打开和关闭拥有一个流畅的效果
        var insertAnimation: UITableViewRowAnimation
        var deleteAnimation: UITableViewRowAnimation
        if previousOpenSectionIndex == NSNotFound || sectionOpened < previousOpenSectionIndex {
            insertAnimation = UITableViewRowAnimation.Fade
            deleteAnimation = UITableViewRowAnimation.Fade
        }else{
            insertAnimation = UITableViewRowAnimation.Fade
            deleteAnimation = UITableViewRowAnimation.Fade
        }
        
        // 应用单元格的更新
        self.tableView.beginUpdates()
        
        //println("delete \(indexPathsToDelete) == insert\(indexPathsToInsert)")
        self.tableView.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation: deleteAnimation)
        self.tableView.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation: insertAnimation)
        opensectionindex = sectionOpened
        
        self.tableView.endUpdates()
        
        self.preopenindex = sectionOpened  //2015-04-04 本次打开之后 将当前setion记录为上次打开的section
    }
    
    func innerAddressBookHeader(innerAddressBookHeader: InnerAddressBookHeader, sectionClosed: Int) {
        //println("-----------section close------------")
        // 在表格关闭的时候，创建一个包含单元格索引路径的数组，接下来从表格中删除这些行
        let sectionInfo: SectionInfo = self.sectionInfoArray[sectionClosed] as! SectionInfo
        sectionInfo.headerView.HeaderOpen = false
        sectionInfo.headerView.ImgNarrow.image = UIImage(named:"narrow_right")
        opensectionindex = NSNotFound
        
        let countOfRowsToDelete = self.tableView.numberOfRowsInSection(sectionClosed)
        
        if countOfRowsToDelete > 0 {
            //var indexPathsToDelete = NSMutableArray()
            var indexPathsToDelete:[NSIndexPath] = []
            for (var i = 0; i < countOfRowsToDelete; i++) {
                indexPathsToDelete.append(NSIndexPath(forRow: i, inSection: sectionClosed))
            }
            self.tableView.beginUpdates()
            self.tableView.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation: UITableViewRowAnimation.Fade)
            self.tableView.endUpdates()
        }
        //opensectionindex = NSNotFound
        
        self.preopenindex = NSNotFound
    }
    /*
    //没有story board 所以没有seque
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    println("prepareForSeque \(segue.identifier)")
    if segue.identifier == "Detail" {
    
    let candyDetailViewController = segue.destinationViewController as UIViewController
    
    if sender as UITableView == self.searchDisplayController!.searchResultsTableView {
    
    let indexPath = self.searchDisplayController!.searchResultsTableView.indexPathForSelectedRow()!
    
    let destinationTitle = self.filteredItemList[indexPath.row].name
    
    candyDetailViewController.title = destinationTitle
    
    } else {
    
    let indexPath = self.tableView.indexPathForSelectedRow()!
    
    let destinationTitle = self.itemlist[indexPath.row].name
    
    candyDetailViewController.title = destinationTitle
    
    }
    
    }
    
    }
    */
    
}
