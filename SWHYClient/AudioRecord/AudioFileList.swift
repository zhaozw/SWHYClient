//
//  AudioFileList.swift
//  SWHYClient_DEV
//
//  Created by sunny on 9/4/16.
//  Copyright © 2016 DY-INFO. All rights reserved.
//

import UIKit
@objc(AudioFileList) class AudioFileList: UITableViewController,UISearchBarDelegate, UISearchDisplayDelegate {
    var itemlist = [AudioFileItem]()
    var filteredItemList = [AudioFileItem]()
    @IBOutlet weak var searchBar: UISearchBar!
    var rightBtn:UIButton?
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?){
       
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    convenience init() {
         self.init(nibName: "AudioFileList", bundle: nil)

    }
    
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.title = "录音库"
        print("view did load")
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        
        //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        let _ = AudioListCell()
        let nib = UINib(nibName:"AudioListCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "Cell")
        self.searchDisplayController?.searchResultsTableView.registerNib(nib, forCellReuseIdentifier: "Cell")
        setupRightBarItem()
    }
    
    func getFileList(){
        //self.items = DaiFileManager.document["/Audio/"].files.all()
        self.itemlist.removeAll()
        var items = DaiFileManager.document["/Audio/"].files.filter(".mp3")
        
        
        if items.isEmpty {
            print("audio file list empty")
            //self.itemlist = nil
        } else{
            
            for (index, elem ) in items.enumerate() {
                
                let audioFileItem:AudioFileItem = AudioFileItem()
                
                //print(elem)
                audioFileItem.title = DaiFileManager.document["/Audio/"+elem].getAttr("C_Title")
                audioFileItem.filename = elem
                audioFileItem.description = DaiFileManager.document["/Audio/"+elem].getAttr("C_Desc")
                audioFileItem.url = DaiFileManager.document["/Audio/"+elem].getAttr("C_URL")
                audioFileItem.duration = DaiFileManager.document["/Audio/"+elem].getAttr("C_Duration")
                
                audioFileItem.query = audioFileItem.title + audioFileItem.description
                
                self.itemlist.append(audioFileItem)
                
            } 
            
            //self.itemlist.addObject(audioFileItem)
        }
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let backitem = UIBarButtonItem(title: Config.UI.PreNavItem, style: UIBarButtonItemStyle.Plain, target: self, action: "returnNavView")
        self.navigationItem.leftBarButtonItem = backitem

        print("table reload data")
        getFileList()
        self.tableView.reloadData()
    }
    
    func returnNavView(){
        let audioRecorderViewController:AudioRecorder = AudioRecorder()
        let nvc=UINavigationController(rootViewController:audioRecorderViewController);
        self.slideMenuController()?.changeMainViewController(nvc, close: true)
    }
    
    func setupRightBarItem(){
        
        //self.rightBtn = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        self.rightBtn = UIButton(type: UIButtonType.Custom)
        self.rightBtn!.frame = CGRectMake(0,0,50,40)
        //self.rightBtn?.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        self.rightBtn?.setTitle("管理", forState: UIControlState.Normal)
        self.rightBtn!.tag = 100
        self.rightBtn!.userInteractionEnabled = true
        self.rightBtn?.addTarget(self, action: "rightBarItemClicked", forControlEvents: UIControlEvents.TouchUpInside)
        var barButtonItem = UIBarButtonItem(customView: self.rightBtn!)
        self.navigationItem.rightBarButtonItem = barButtonItem
        
        
        
    }
    func rightBarItemClicked(){
        print("rightBarItemClicked \(self.rightBtn!.tag)")
        if (self.rightBtn!.tag == 100)
        {
            self.tableView?.setEditing(true, animated: true)
            self.rightBtn!.tag = 200
            self.rightBtn?.setTitle("完成", forState: UIControlState.Normal)
            //将增加按钮设置不能用
            //self.rightButtonItem!.enabled=false
        }
        else
        {
            //恢复增加按钮
            //self.rightButtonItem!.enabled=true
            self.tableView?.setEditing(false, animated: true)
            self.rightBtn!.tag = 100
            self.rightBtn?.setTitle("管理", forState: UIControlState.Normal)
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
            return 1
        }
        
    }
    
    // UITableViewDataSource Functions
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.searchDisplayController?.searchResultsTableView {
            return self.filteredItemList.count
        } else {
            return self.itemlist.count
        }
    }

    //删除一行
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!){
        print(editingStyle)
        var index=indexPath.row as Int
        self.itemlist.removeAtIndex(index)
        self.tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
        NSLog("删除\(indexPath.row)")
    }
    
    override func tableView(tableView: UITableView!, editActionsForRowAtIndexPath indexPath: NSIndexPath) ->  [UITableViewRowAction]?{
        /*
        let more = UITableViewRowAction(style: .Normal, title: "More") { action, index in
            print("more button tapped")
        }
        more.backgroundColor = UIColor.lightGrayColor()
        
        let favorite = UITableViewRowAction(style: .Normal, title: "Favorite") { action, index in
            print("favorite button tapped")
        }
        favorite.backgroundColor = UIColor.orangeColor()
        */
        let delete = UITableViewRowAction(style: .Default, title: "删除") { action, index in
            print("delete button tapped")
            
            
            let btn_OK:PKButton = PKButton(title: "删除",
                                           action: { (messageLabel, items) -> Bool in
                                            var index=indexPath.row as Int
                                            DaiFileManager.document["/Audio/"+self.itemlist[index].filename].delete()
                                            
                                            self.itemlist.removeAtIndex(index)
                                            self.tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
                                            NSLog("删除 tap \(indexPath.row)")
                                            PKNotification.toast("已成功删除")
                                            return true
                                            },
                                           fontColor: UIColor(red: 0, green: 0.55, blue: 0.9, alpha: 1.0),
                                           backgroundColor: nil)
            
            // call alert
            PKNotification.alert(
                title: "删除",
                message: "确认删除指定的录音?",
                items: [btn_OK],
                cancelButtonTitle: "取消",
                tintColor: nil)
            
            
            
            /*
            var index=indexPath.row as Int
            print(self.itemlist[index])
            DaiFileManager.document["/Audio/"+self.itemlist[index].filename].delete()
            
            self.itemlist.removeAtIndex(index)
            self.tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
            NSLog("删除 tap \(indexPath.row)")
            */
        }
        delete.backgroundColor = UIColor.redColor()
        return [delete]
        //return [delete, favorite, more]
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 在tableview中查询一个条目，如果没有创建一个。
       
        // 从我们的糖果数组中获得相应的内容
        var item:AudioFileItem
        
        if tableView == self.searchDisplayController?.searchResultsTableView {
            //print("cell for search")
            item = filteredItemList[indexPath.row]
            
        } else {
            //print("cell for content")
            item = self.itemlist[indexPath.row] as AudioFileItem
        }
        
        let cell:AudioListCell! = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? AudioListCell
       
        //cell.textLabel?.text = item.name
        
        cell.title.text = item.title == "" ? item.filename : item.title
       
        if item.url == ""{
            cell.icon?.image = UIImage(named: "audio")
        }else{
            cell.icon?.image = UIImage(named: "audio_cloud")
        }
        
        cell.duration.text = item.duration
        //cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        //println("---end cellForRowAtIndexPath section----")
       
        return cell
         
    }

    func filterContentForSearchText(searchText: String) {
        // 使用过滤方法过滤数组 陈陈
        print("filterContentForSearchText \(searchText)")
        self.filteredItemList = self.itemlist.filter({( audioFileItem: AudioFileItem) -> Bool in
            let stringMatch = audioFileItem.query.rangeOfString(searchText)
              return (stringMatch != nil)
        })
    }
    
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String?) -> Bool { 
        print("searchDisplayController = \(searchString)")
        self.filterContentForSearchText(searchString!)
        return true   
    }
    
    
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        print("searchDisplayController Search Scope")
        self.filterContentForSearchText(self.searchDisplayController!.searchBar.text!)
        return true 
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        print("did select row at index path =\(indexPath)")
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var item:AudioFileItem
        
        if tableView == self.searchDisplayController?.searchResultsTableView {
            item = self.filteredItemList[indexPath.row] as AudioFileItem
 
        } else {
            item = self.itemlist[indexPath.row] as AudioFileItem
            
        }

        let nextController:AudioDetail = AudioDetail()
        Message.shared.audioFileName = self.itemlist[indexPath.row].filename
        self.navigationController?.pushViewController(nextController,animated:false);
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
        
}
