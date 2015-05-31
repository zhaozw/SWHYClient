//
//  SwiftViewController.swift
//  SWHYClient
//
//  Created by sunny on 5/13/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//

import UIKit

class UIImageViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var btn_customize: UIButton!
    @IBOutlet weak var bgview1: UIView!
    @IBOutlet weak var bgview2: UIView!
    @IBOutlet weak var bgview3: UIView!
    @IBOutlet weak var bgview4: UIView!
    @IBOutlet weak var bgview5: UIView!
    @IBOutlet weak var bgview6: UIView!
    @IBOutlet weak var chk1: UIImageView!
    @IBOutlet weak var chk2: UIImageView!
    @IBOutlet weak var chk3: UIImageView!
    @IBOutlet weak var chk4: UIImageView!
    @IBOutlet weak var chk5: UIImageView!
    @IBOutlet weak var chk6: UIImageView!
    
    @IBOutlet weak var bgimageview6: UIImageView!
    
    @IBAction func btnCustomImage(sender: AnyObject) {
        
        var btn=UIImagePickerController()
        btn.sourceType=UIImagePickerControllerSourceType.PhotoLibrary
        btn.delegate=self
        //To display the UIImagePickerController
        self.presentViewController(btn, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        bgimageview6.image=image
        //return and show the image
        
        let data:NSData
        let filename:String = "uibg_customize"
        
        if (UIImagePNGRepresentation(image) == nil) {
            data = UIImageJPEGRepresentation(image, 1);
        } else {
            data = UIImagePNGRepresentation(image);
            filename         
        }
        
        Util.applicationCreatFileAtPath(fileTypeDirectory: false, fileName: filename, directory: nil, content: data)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap_bgview1:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClick_tapView:")
        bgview1.addGestureRecognizer(tap_bgview1)
        
        let tap_bgview2:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClick_tapView:")
        bgview2.addGestureRecognizer(tap_bgview2)
        
        let tap_bgview3:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClick_tapView:")
        bgview3.addGestureRecognizer(tap_bgview3)
        
        let tap_bgview4:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClick_tapView:")
        bgview4.addGestureRecognizer(tap_bgview4)
        
        let tap_bgview5:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClick_tapView:")
        bgview5.addGestureRecognizer(tap_bgview5)
        
        let tap_bgview6:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClick_tapView:")
        bgview6.addGestureRecognizer(tap_bgview6)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "登陆界面设置"
        
        let backitem = UIBarButtonItem(title: Config.UI.PreNavItem, style: UIBarButtonItemStyle.Plain, target: self, action: "returnNavView")
        self.navigationItem.leftBarButtonItem = backitem
        self.setNavigationBarItem()
        
        let viewlist = [bgview1 , bgview2 , bgview3 , bgview4 , bgview5 , bgview6] as [UIView]
        let chklist = [chk1 , chk2 , chk3 , chk4 , chk5 , chk6] as [UIImageView]
        
        let uiindex = NSUserDefaults.standardUserDefaults().integerForKey("UIBackgroundImage")
        for (var i = 0;i < viewlist.count;i++){
            viewlist[i].bringSubviewToFront(chklist[i])
            if uiindex == i {
                
                chklist[i].hidden = false
            }else{
                chklist[i].hidden = true
            }
        }
        
        var filePath = Util.applicationFilePath ("uibg_customize", directory: nil)
        let image = UIImage(contentsOfFile: filePath)
        
        bgimageview6.image=image
        
    }
    
    
    func onClick_tapView(sender:UITapGestureRecognizer!){
        println(" tap ")
        let viewlist = [bgview1 , bgview2 , bgview3 , bgview4 , bgview5 , bgview6] as [UIView]
        let chklist = [chk1 , chk2 , chk3 , chk4 , chk5 , chk6] as [UIImageView]
        
        
        for (var i = 0;i < viewlist.count;i++){
            //viewlist[i].bringSubviewToFront(chklist[i])
            if sender.view == viewlist[i] {
                chklist[i].hidden = chklist[i].hidden ? false : true
                //如果显示 则更新设置档
                
                if chklist[i].hidden == false {
                    //UI背景直接序号就行了
                    NSUserDefaults.standardUserDefaults().setObject(i, forKey: "UIBackgroundImage")
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
                
            }else{
                chklist[i].hidden = true
            }
        }         
    }
    
    
    /*
    // 使用系统的图片选取器
    func showSystemController() {
    let pickerController = UIImagePickerController()
    pickerController.delegate = self
    pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    //pickerController.mediaTypes = [kUTTypeImage!,kUTTypeMovie!]
    
    self.presentViewController(pickerController, animated: true) {}
    }
    
    // 使用自定义的图片选取器
    func showCustomController() {
    let pickerController = DKImagePickerController()
    pickerController.pickerDelegate = self
    self.presentViewController(pickerController, animated: true) {}
    }
    
    
    func imagePickerControllerCancelled() {
    self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidSelectedAssets(assets: [DKAsset]!) {
    for (index, asset) in enumerate(assets) {
    
    }
    
    self.dismissViewControllerAnimated(true, completion: nil)
    }    
    */
    func returnNavView(){
        println("click return button")
        
        let mainViewController:MainViewController = MainViewController()
        let nvc=UINavigationController(rootViewController:mainViewController);
        
        var storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let rightViewController = storyboard.instantiateViewControllerWithIdentifier("MenuViewController") as! MenuViewController
        
        let slideMenuController = SlideMenuController(mainViewController: nvc, rightMenuViewController: rightViewController)
        //self.window?.rootViewController = slideMenuController
        UIApplication.sharedApplication().keyWindow?.rootViewController = slideMenuController
        
        
    }
    
}