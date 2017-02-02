//
//  FileViewContorller.swift
//  SWHYClient_DEV
//
//  Created by sunny on 8/6/16.
//  Copyright © 2016 DY-INFO. All rights reserved.
//


import UIKit

@objc(FileViewController) class FileViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var tableView : UITableView?
    var items = ["武汉","上海","北京","深圳","广州","重庆","香港","台海","天津"]
    var rightBtn:UIButton?
    //var rightButtonItem:UIBarButtonItem?
    
    init() {
        print("init")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        print(" init code")
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        print("do did load fileview controller")
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        initView()
        getFileList()
        setupRightBarItem()
        //setupRightBarButtonItem()
        //setupLeftBarButtonItem()
        //self.leftBtn!.userInteractionEnabled = true
        
        // Do any additional setup after loading the view.
    }
    
    func initView(){
        // 初始化tableView的数据
        self.tableView=UITableView(frame:self.view.frame,style:UITableViewStyle.Plain)
        // 设置tableView的数据源
        self.tableView!.dataSource=self
        // 设置tableView的委托
        self.tableView!.delegate = self
        //
        self.tableView!.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.tableView!)
        
        
    }
    func getFileList(){
        //self.items = DaiFileManager.document["/Audio/"].files.all()
        self.items = DaiFileManager.document["/Audio/"].files.filter(".mp3")
        //filter("Empty")
    }
    
    override func viewWillAppear(animated: Bool) {
        print("viewwill appear")
        super.viewWillAppear(animated)
        self.title = "录音库"
            
        let backitem = UIBarButtonItem(title: Config.UI.PreNavItem, style: UIBarButtonItemStyle.Plain, target: self, action: "returnNavView")
        self.navigationItem.leftBarButtonItem = backitem
        self.setNavigationBarItem()
                
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
       
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //总行数
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int{
        return self.items.count
    }
    
    //加载数据
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!{
        
        let cell = tableView .dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        var row=indexPath.row as Int
        cell.textLabel!.text=self.items[row]
        cell.imageView!.image = UIImage(named:"green.png")
        return cell;
        
    }
    
    //删除一行
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!){
        print(editingStyle)
        var index=indexPath.row as Int
        self.items.removeAtIndex(index)
        self.tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
        NSLog("删除\(indexPath.row)")
    }
    //选择一行
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!){
        //let alert = UIAlertView()
        //alert.title = "提示"
        //alert.message = "你选择的是\(self.items[indexPath.row])"
        //alert.addButtonWithTitle("Ok")
       // alert.show()
        
        let nextController:AudioDetail = AudioDetail()
        Message.shared.audioFileName = self.items[indexPath.row]
        self.navigationController?.pushViewController(nextController,animated:false);

    }
    
    func tableView(tableView: UITableView!, editActionsForRowAtIndexPath indexPath: NSIndexPath) ->  [UITableViewRowAction]?{
        let more = UITableViewRowAction(style: .Normal, title: "More") { action, index in
            print("more button tapped")
        }
        more.backgroundColor = UIColor.lightGrayColor()
        
        let favorite = UITableViewRowAction(style: .Normal, title: "Favorite") { action, index in
            print("favorite button tapped")
        }
        favorite.backgroundColor = UIColor.orangeColor()
        
        let delete = UITableViewRowAction(style: .Normal, title: "删除") { action, index in
            print("delete button tapped")
            var index=indexPath.row as Int
            print(self.items[index])
            DaiFileManager.document["/Audio/"+self.items[index]].delete()
            
            self.items.removeAtIndex(index)
            self.tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
            NSLog("删除 tap \(indexPath.row)")

        }
        delete.backgroundColor = UIColor.redColor()
        
        return [delete, favorite, more]
    }
    
    
}
