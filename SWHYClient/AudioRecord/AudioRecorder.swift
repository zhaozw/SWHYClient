//
//  AudioRecorder.swift
//  SWHYClient_DEV
//
//  Created by sunny on 7/31/16.
//  Copyright © 2016 DY-INFO. All rights reserved.
//

import Foundation
import AVFoundation
import AudioKit
//protocol AudioRecorderViewControllerDelegate: class {
//   func audioRecorderViewControllerDismissed(withFileURL fileURL: NSURL?)
//}

//AVAudioRecorderDelegate

@objc(AudioRecorder) class AudioRecorder: UIViewController,AVAudioPlayerDelegate{
    
    
    //@IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var btn_Record: UIButton!
    @IBOutlet weak var btn_Play: UIButton!
    @IBOutlet weak var btn_Save: UIButton!
    @IBOutlet weak var btn_pause: UIButton!
    
    @IBOutlet var audioInputPlot: EZAudioPlot!
    
    var timeTimer: NSTimer?
    var timeinterval:NSTimeInterval?
    //var milliseconds: Int = 0
    
    var recorder: AVAudioRecorder?
    var player: AVAudioPlayer?
    var outputURL: NSURL = NSURL()
    var audioTmpPath:String = ""
    var audioPath:String = ""
    var audioTmpFilePath:String  = ""
    var audioFilePath:String  = ""
    //var recording:String = ""
    var audioTmpFileName:String = ""
    var audioFileName:String = ""
    
    var tmptitle:String = ""
    var tmpdesc:String = ""
    
    var recordercolor:UIColor?
    
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    var plot:AKNodeOutputPlot!
    
    var image_record_stop:UIImage = UIImage(named:"btn_record_stop")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
    var image_record_record:UIImage = UIImage(named:"btn_record_record")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
    
    var but1:UIButton!
    var but2:UIButton!
    var but3:UIButton!
    var but4:UIButton!
    var but5:UIButton!
    var butlist:[UIButton]!
    
    
    //let noteFrequencies = [16.35,17.32,18.35,19.45,20.6,21.83,23.12,24.5,25.96,27.5,29.14,30.87]
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?){
        //let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        // let outputPath = documentsPath.stringByAppendingPathComponent("\(NSUUID().UUIDString).m4a")
        //outputURL = NSURL(fileURLWithPath: outputPath)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    convenience init() {
        self.init(nibName: "AudioRecorder", bundle: nil)
        // self.init
        //self.init(nibName: "LaunchScreen", bundle: nil)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = Message.shared.curMenuItem.name
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        DaiFileManager.document["/Audio_Tmp/"].delete()
        
        self.audioTmpPath = DaiFileManager.document["/Audio_Tmp/"].path
        self.audioPath = DaiFileManager.document["/Audio/"].path
        
        //btn_Record.userInteractionEnabled = true
        //self.recordercolor = btn_Record.backgroundColor
        
        
        mic = AKMicrophone()
        tracker = AKFrequencyTracker.init(mic)
        silence = AKBooster(tracker, gain: 0)
        plot = AKNodeOutputPlot(mic, frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 100))
        
        //初始化record-----------------------------------------
        let dateFormatter:NSDateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "yyyyMMddHHmmss";
        let tmpdate = "\(dateFormatter.stringFromDate(NSDate()))"
        //LinearPCM
        self.audioTmpFileName = tmpdate+".wav"
        self.audioFileName = tmpdate+".mp3"
        
        self.audioTmpFilePath = self.audioTmpPath + self.audioTmpFileName        
        self.audioFilePath = self.audioPath + self.audioFileName
        
        outputURL = NSURL(fileURLWithPath: audioTmpFilePath)
        
        let settings = [AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatLinearPCM),//编码格式
            AVSampleRateKey: NSNumber(integer: 44100), //声音采样率
            AVNumberOfChannelsKey: NSNumber(integer: 2),////采集音轨
            AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.High.rawValue))//音量
        ]
        try! recorder = AVAudioRecorder(URL: outputURL, settings: settings)
        //recorder.delegate = self
        
    }
    
    
    func setupPlot() {
        print("setupPlot")
        plot.plotType = .Rolling
        //plot.plotType = .Buffer
        plot.shouldFill = true
        plot.gain = 5 as Float
        
        //plot.backgroundColor = UIColor.darkGrayColor()
        
        plot.shouldMirror = true
        //plot.color = UIColor.lightGrayColor()
        plot.color = UIColor.init(red: 45/255, green: 184/255, blue: 105/255, alpha: 1)
        //plot.color = UIColor.init(red: 0/255, green: 128/255, blue: 0/255, alpha: 1)
        //plot.color = UIColor.init(red: 0/255, green: 64/255, blue: 128/255, alpha: 1)
        
        print(plot.frame)
        plot.clear()
        
        audioInputPlot.addSubview(plot)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("view will appear")
        let backitem = UIBarButtonItem(title: Config.UI.PreNavItem, style: UIBarButtonItemStyle.Plain, target: self, action: "returnNavView")
        self.navigationItem.leftBarButtonItem = backitem
        
        let rightitem = UIBarButtonItem(title: "录音库 >", style: UIBarButtonItemStyle.Plain, target: self, action: "gotoNavView")
        self.navigationItem.rightBarButtonItem = rightitem
        
        AudioKit.output = silence
        setupPlot()
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch let error as NSError {
            NSLog("Error: \(error)")
        }
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopRecording:", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //NSNotificationCenter.defaultCenter().removeObserver(self)
        cleanup()
        
    }
    
    
    func returnNavView(){
        print("click return button")
        //self.navigationController?.popViewControllerAnimated(true)
        
        if btn_pause.hidden == false{
            if btn_pause.currentTitle == "录音暂停" {
                print("recording  and not allow to return")
                PKNotification.toast("录音时不能离开录音界面!")
                return
            }else if btn_pause.currentTitle == "录音继续" {
                print("dd")
                let btn_OK:PKButton = PKButton(title: "确定",
                                               action: { (messageLabel, items) -> Bool in
                                                print("=========click==========)")
                                                //===code here
                                                let mainViewController:MainViewController = MainViewController()
                                                let nvc=UINavigationController(rootViewController:mainViewController)
                                                self.slideMenuController()?.changeMainViewController(nvc, close: true)
                                                return true
                    },
                                               fontColor: UIColor(red: 0, green: 0.55, blue: 0.9, alpha: 1.0),
                                               backgroundColor: nil)
                
                // call alert
                PKNotification.alert(
                    title: "微录音",
                    message: "放弃本次录音,并离开?",
                    items: [btn_OK],
                    cancelButtonTitle: "取消",
                    tintColor: nil)
            }
            return
        }
        
        let mainViewController:MainViewController = MainViewController()
        let nvc=UINavigationController(rootViewController:mainViewController)
        self.slideMenuController()?.changeMainViewController(nvc, close: true)
        
    }
    
    func gotoNavView(){
        print("click goto button")
        //self.navigationController?.popViewControllerAnimated(true)
        if btn_pause.hidden == false{
            if btn_pause.currentTitle == "录音暂停" {
                print("recording  and not allow to return")
                PKNotification.toast("录音时不能离开录音界面!")
                return
            }else if btn_pause.currentTitle == "录音继续" {
                print("dd")
                let btn_OK:PKButton = PKButton(title: "确定",
                                               action: { (messageLabel, items) -> Bool in
                                                print("=========click==========)")
                                                //===code here
                                                let fileViewController:AudioFileList = AudioFileList()
                                                let nvc=UINavigationController(rootViewController:fileViewController)
                                                self.slideMenuController()?.changeMainViewController(nvc, close: true)
                                                
                                                return true
                    },
                                               fontColor: UIColor(red: 0, green: 0.55, blue: 0.9, alpha: 1.0),
                                               backgroundColor: nil)
                
                // call alert
                PKNotification.alert(
                    title: "微录音",
                    message: "放弃本次录音,并离开?",
                    items: [btn_OK],
                    cancelButtonTitle: "取消",
                    tintColor: nil)
            }
            return
        }
        
        //let fileViewController:FileViewController = FileViewController()
        let fileViewController:AudioFileList = AudioFileList()
        let nvc=UINavigationController(rootViewController:fileViewController)
        self.slideMenuController()?.changeMainViewController(nvc, close: true)
        
    }
    
    func audioRecorderViewControllerDismissed(withFileURL fileURL: NSURL?) {
        // do something with fileURL
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //func dismiss(sender: AnyObject) {
    //    cleanup()
    //    self.audioRecorderViewControllerDismissed(withFileURL: nil)
    // }
    
    
    @IBAction func saveAudio(sender: AnyObject) {
        
        
        let txtTitle:UITextField = UITextField()
        txtTitle.placeholder = "标题"
        txtTitle.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 1.0, alpha: 1.0)
        txtTitle.textColor = UIColor.darkGrayColor()
        
        /*
         let txtDesc:UITextField = UITextField()
         txtDesc.placeholder = "摘要"
         txtDesc.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 1.0, alpha: 1.0)
         txtDesc.textColor = UIColor.darkGrayColor()
         */
        
        ///*
        //let txtDesc:UITextView = UITextView(frame:CGRectMake(0,0,200,100))
        var placeholderLabel:UILabel!
        let txtDesc:UITextView = UITextView()
        txtDesc.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 1.0, alpha: 1.0)
        txtDesc.textColor = UIColor.darkGrayColor()
        txtDesc.textContainer.lineFragmentPadding = 0; 
        txtDesc.textContainerInset = UIEdgeInsetsZero;
        //txtDesc.layoutMargins = UIEdgeInsetsMake(50, 0, 0, 0);
        placeholderLabel = UILabel.init() // placeholderLabel是全局属性  
        placeholderLabel.frame = CGRectMake(5 , 5, 100, 20)  
        placeholderLabel.font = UIFont.systemFontOfSize(14)  
        placeholderLabel.text = "摘要"  
        //placeholderLabel.backgroundColor = UIColor.purpleColor() 
        placeholderLabel.textColor = UIColor.lightGrayColor()  
        /*placeholderLabel.layoutMargins = UIEdgeInsets(
         top: 0,
         left: 40,
         bottom: 0,
         right: 0)
         */
        txtDesc.addSubview(placeholderLabel)  
        //self.placeholderLabel.textColor = UIColor.init(colorLiteralRed: 72/256, green: 82/256, blue: 93/256, alpha: 1)  
        
        //*/
        //var flatSwitch = AIFlatSwitch(frame: CGRectMake(0, 0, 50, 50))
        
        let labelView:UIView = UIView()
        labelView.userInteractionEnabled=true
        
        /*
         var label1:UILabel!
         label1 = UILabel.init() // placeholderLabel是全局属性  
         label1.frame = CGRectMake(0 , 5, 40, 20)  
         label1.font = UIFont.systemFontOfSize(14)  
         //label1.text = "公开"
         label1.backgroundColor = UIColor.purpleColor() 
         label1.textColor = UIColor.lightGrayColor()
         label1.userInteractionEnabled=true
         let tap = UITapGestureRecognizer.init(target: self, action: Selector.init("tapLabel1"))
         
         //let tap = UITapGestureRecognizer.init(target: self, action: #selector(AudioRecorder.userClick(sender:)))
         label1.addGestureRecognizer(tap)
         */
        
        //var but1:UIButton!
        but1 = UIButton.init()
        but1.frame = CGRectMake(0 , 5, 30, 20) 
        but1.backgroundColor = UIColor.redColor() 
        but1.setTitle("公开", forState:UIControlState.Normal)
        but1.titleLabel!.font = UIFont.systemFontOfSize(13) 
        but1.layer.cornerRadius = 4
        but1.layer.borderColor = UIColor.lightGrayColor().CGColor  
        but1.layer.borderWidth = 0
        
        but1.addTarget(self, action: "clickbtn:", forControlEvents: UIControlEvents.TouchUpInside)
        labelView.addSubview(but1)
        
        
        //var but2:UIButton!
        but2 = UIButton.init()
        but2.frame = CGRectMake(35 , 5, 45, 20) 
        but2.backgroundColor = UIColor.redColor()
        but2.setTitle("研究所", forState:UIControlState.Normal)
        but2.titleLabel!.font = UIFont.systemFontOfSize(13) 
        but2.layer.cornerRadius = 4
        but2.layer.borderColor = UIColor.lightGrayColor().CGColor  
        but2.layer.borderWidth = 0
        but2.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        but2.addTarget(self, action: "clickbtn:", forControlEvents: UIControlEvents.TouchUpInside)
        labelView.addSubview(but2)
        
        //var but3:UIButton!
        but3 = UIButton.init()
        but3.frame = CGRectMake(85 , 5, 55, 20) 
        but3.backgroundColor = UIColor.redColor() 
        but3.setTitle("机构客户", forState:UIControlState.Normal)
        but3.titleLabel!.font = UIFont.systemFontOfSize(13) 
        but3.layer.cornerRadius = 4
        but3.layer.borderColor = UIColor.lightGrayColor().CGColor  
        but3.layer.borderWidth = 0
        but3.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        but3.addTarget(self, action: "clickbtn:", forControlEvents: UIControlEvents.TouchUpInside)
        labelView.addSubview(but3)
        
        //var but4:UIButton!
        but4 = UIButton.init()
        but4.frame = CGRectMake(145 , 5, 35, 20) 
        but4.backgroundColor = UIColor.redColor() 
        but4.setTitle("投顾", forState:UIControlState.Normal)
        but4.titleLabel!.font = UIFont.systemFontOfSize(13)
        but4.layer.cornerRadius = 4
        but4.layer.borderColor = UIColor.lightGrayColor().CGColor  
        but4.layer.borderWidth = 0
        but4.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        but4.addTarget(self, action: "clickbtn:", forControlEvents: UIControlEvents.TouchUpInside)
        labelView.addSubview(but4)
        
        //var but5:UIButton!
        but5 = UIButton.init()
        but5.frame = CGRectMake(185 , 5, 55, 20) 
        but5.backgroundColor = UIColor.redColor()
        but5.setTitle("认证客户", forState:UIControlState.Normal)
        but5.titleLabel!.font = UIFont.systemFontOfSize(13) 
        but5.layer.cornerRadius = 4
        but5.layer.borderColor = UIColor.lightGrayColor().CGColor  
        but5.layer.borderWidth = 0
        but5.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        but5.addTarget(self, action: "clickbtn:", forControlEvents: UIControlEvents.TouchUpInside)
        labelView.addSubview(but5)
        
        butlist = [but1,but2,but3,but4,but5]
        print(butlist.count)
        
        let btnOK:PKButton = PKButton(title: "发布",
                                      action: { (messageLabel, items) -> Bool in
                                        print("发布 is clicked.")
                                        let tmptxtTitle: UITextField = items[0] as! UITextField //items index number
                                        //let tmptxtDesc: UITextField = items[1] as! UITextField //items index number
                                        let tmptxtDesc: UITextView = items[1] as! UITextView //items index number
                                        
                                        if (tmptxtTitle.text == "" || tmptxtDesc.text == ""){
                                            messageLabel?.text = "请填写标题与摘要."
                                            tmptxtTitle.backgroundColor = UIColor(red: 0.95, green: 0.8, blue: 0.8, alpha: 1.0)
                                            tmptxtDesc.backgroundColor = UIColor(red: 0.95, green: 0.8, blue: 0.8, alpha: 1.0)
                                            return false
                                        }
                                        
                                        var authtext:String = ""
                                        for item1 in self.butlist {     
                                            if(item1.backgroundColor != nil){
                                                authtext = authtext + item1.currentTitle! + ","
                                            }
                                        }
                                        print(authtext)
                                        
                                        
                                        self.plot.clear()
                                        NSNotificationCenter.defaultCenter().addObserver(self, selector: "HandleResult:", name: Config.NotifyTag.ConvertToMP3AndPublish, object: nil)
                                        self.covertToMP3(tmptxtTitle.text!,desc: tmptxtDesc.text!,auth:authtext,tag:Config.NotifyTag.ConvertToMP3AndPublish)
                                        return true
            },
                                      fontColor: UIColor(red: 0, green: 0.55, blue: 0.9, alpha: 1.0),
                                      backgroundColor: nil)
        
        
        let btnSave:PKButton = PKButton(title: "保存",
                                        action: { (messageLabel, items) -> Bool in
                                            print("保存 is clicked.")
                                            let tmptxtTitle: UITextField = items[0] as! UITextField //items index number
                                            //let tmptxtDesc: UITextField = items[1] as! UITextField //items index number
                                            let tmptxtDesc: UITextView = items[1] as! UITextView //items index number
                                            
                                            if (tmptxtTitle.text == "" || tmptxtDesc.text == ""){
                                                messageLabel?.text = "请填写标题与摘要."
                                                tmptxtTitle.backgroundColor = UIColor(red: 0.95, green: 0.8, blue: 0.8, alpha: 1.0)
                                                tmptxtDesc.backgroundColor = UIColor(red: 0.95, green: 0.8, blue: 0.8, alpha: 1.0)
                                                return false
                                            }
                                            
                                            
                                            var authtext:String = ""
                                            for item1 in self.butlist {     
                                                if(item1.backgroundColor != nil){
                                                    authtext = authtext + item1.currentTitle! + ","
                                                }
                                            }
                                            print(authtext)
                                            self.plot.clear()
                                            NSNotificationCenter.defaultCenter().addObserver(self, selector: "HandleResult:", name: Config.NotifyTag.ConvertToMP3AndSave, object: nil)
                                            //self.covertToMP3(tmptxtTitle.text!,desc: tmptxtDesc.text!)
                                            self.covertToMP3(tmptxtTitle.text!,desc: tmptxtDesc.text!,auth:authtext,tag:Config.NotifyTag.ConvertToMP3AndSave)
                                            return true
            },
                                        fontColor: UIColor(red: 0, green: 0.55, blue: 0.9, alpha: 1.0),
                                        backgroundColor: nil)
        
        let btnCancel:PKButton = PKButton(title: "取消",
                                          action: { (messageLabel, items) -> Bool in
                                            print("取消 is clicked.")
                                            self.plot.clear()
                                            return true
            },
                                          fontColor: UIColor.grayColor(),
                                          backgroundColor: nil)
        
        PKNotification.alert(
            title: "保存或发布",
            message: "保存或发布至公众号",
            items: [txtTitle, txtDesc,labelView,btnCancel,btnSave,btnOK],
            cancelButtonTitle: "如果items里有取消字样的按钮，则会忽略这个取消按钮",
            tintColor: nil)
    }
    
    
    
    func covertToMP3(title:String, desc:String,auth:String,tag:String){
        print("coverttomp3")
        let text = "请稍候，正在发布中..."
        //self.showWaitOverlayWithText(text)
        SwiftOverlays.showBlockingWaitOverlayWithText(text)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            let path = DaiFileManager.document["/Audio_Tmp/" + self.audioTmpFileName].path
            let pathMp3 = DaiFileManager.document["/Audio/" + self.audioFileName].path
            
            AudioWrapper.audioPCMtoMP3(path, pathMp3)
            
            
            DaiFileManager.document["/Audio/"+self.audioFileName].setAttr("C_Title", value: title)
            DaiFileManager.document["/Audio/"+self.audioFileName].setAttr("C_Desc", value: desc)
            DaiFileManager.document["/Audio/"+self.audioFileName].setAttr("C_Auth", value: auth)
            DaiFileManager.document["/Audio/"+self.audioFileName].setAttr("C_Duration", value: self.timeLabel.text!)
            //PKNotification.toast("保存至录音资源库成功")
            dispatch_async(dispatch_get_main_queue(), {
                
                //这里返回主线程，写需要主线程执行的代码
                //println("这里返回主线程，写需要主线程执行的代码  --  Dispatch")
                let result:Result = Result(status: "OK",message:"保存至录音资源库成功",userinfo:NSObject(),tag:tag)
                NSNotificationCenter.defaultCenter().postNotificationName(tag, object: result)
            })
        }
        
    }
    
    
    func HandleResult(notify:NSNotification)
    {
        let result:Result = notify.valueForKey("object") as! Result
        NSNotificationCenter.defaultCenter().removeObserver(self, name: notify.name, object: nil)
        
        if result.status == "Error" {
            print("-------post  error-------------")
            PKNotification.toast(result.message)
            // Remove everything
            //self.removeAllOverlays()
            
            // Don't forget to unblock!
            SwiftOverlays.removeAllBlockingOverlays()
        }else if result.status=="OK"{
            if result.tag == Config.NotifyTag.ConvertToMP3AndSave {
                print(result.message)
                PKNotification.toast(result.message)
                SwiftOverlays.removeAllBlockingOverlays()
                //接着直接上传录音至服务器
                //let filePath = DaiFileManager.document["/Audio/"+self.audioFileName].path
                //NSNotificationCenter.defaultCenter().addObserver(self, selector: "HandleResult:", name: Config.RequestTag.PostUploadAudioFile, object: nil)
                //NetworkEngine.sharedInstance.postUploadFile(Config.URL.PostUploadAudioFile, filePath: filePath, tag: Config.RequestTag.PostUploadAudioFile)
            }else if result.tag == Config.NotifyTag.ConvertToMP3AndPublish {
                print(result.message)
                //PKNotification.toast(result.message)
                
                //接着直接上传录音至服务器
                let filePath = DaiFileManager.document["/Audio/"+self.audioFileName].path
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "HandleResult:", name: Config.RequestTag.PostUploadAudioFile, object: nil)
                NetworkEngine.sharedInstance.postUploadFile(Config.URL.PostUploadAudioFile, filePath: filePath, tag: Config.RequestTag.PostUploadAudioFile)
            }else if result.tag == Config.RequestTag.PostUploadAudioFile{
                DaiFileManager.document["/Audio/"+self.audioFileName].setAttr("C_URL", value: Config.URL.AudioBaseURL + Message.shared.postUserName + "_" + self.audioFileName)
                //PKNotification.toast(result.message)
                print(result.message)
                //上传成功的话 就获取weixin token
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "HandleResult:", name: Config.RequestTag.GetWeiXinToken, object: nil)
                NetworkEngine.sharedInstance.addRequestWithUrlString(Config.URL.GetWeiXinToken, tag: Config.RequestTag.GetWeiXinToken, useCache: false) 
                
            }else if result.tag == Config.RequestTag.GetWeiXinToken{
                print(result.message)
                //得到token成功  发送音频信息及URL
                
                /*
                 {
                 "title":"TITLE",         //标题 
                 "content ":"CONTENT",    //内容
                 "audiourl":"AUDIOURL",   //音频链接 
                 "authorid ":"AUTHORID"   //作者工号
                 }
                 */
                let title = DaiFileManager.document["/Audio/"+self.audioFileName].getAttr("C_Title")
                let content = DaiFileManager.document["/Audio/"+self.audioFileName].getAttr("C_Desc")
                let auth = DaiFileManager.document["/Audio/"+self.audioFileName].getAttr("C_Auth")
                let audiourl = DaiFileManager.document["/Audio/"+self.audioFileName].getAttr("C_URL")
                let authorid = Message.shared.EmployeeId!
                print(auth)
                var authkey:String = ""
                if auth.componentsSeparatedByString("公开").count > 1 { 
                    authkey = "1111111111"
                } else { 
                    if auth.componentsSeparatedByString("研究所").count > 1 {  
                        authkey = authkey + "1" 
                    } else {  
                        authkey = authkey + "0"
                    }  
                    if auth.componentsSeparatedByString("机构客户").count > 1 {  
                        authkey = authkey + "1" 
                    } else {  
                        authkey = authkey + "0"
                    } 
                    if auth.componentsSeparatedByString("投顾").count > 1 {  
                        authkey = authkey + "1" 
                    } else {  
                        authkey = authkey + "0"
                    }
                    if auth.componentsSeparatedByString("认证客户").count > 1 {  
                        authkey = authkey+"1" 
                    } else {  
                        authkey = authkey + "0"
                    }
                    authkey = authkey + "000000"
                }
                print(Message.shared.EmployeeId)
                print(authkey)
                //let json = "{\"title\":\"\(title)\",\"content\":\"\(content)\",\"audiourl\":\"\(audiourl)\",\"authorid\":\"\(authorid)\"}"
                let json = "{title:\"\(title)\",content:\"\(content)\",audiourl:\"\(audiourl)\",authorid:\"\(authorid)\",cardpermission:\"\(authkey)\"}"
                print(json)
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "HandleResult:", name: Config.RequestTag.PostAudioTopic, object: nil)
                //tk001hkieder25091
                
                print(Config.URL.PostAudioTopic+result.message)
                NetworkEngine.sharedInstance.postRequestWithUrlString(Config.URL.PostAudioTopic+result.message, postData:json,tag:Config.RequestTag.PostAudioTopic)
                
            }else if result.tag == Config.RequestTag.PostAudioTopic{
                //result.userinfo as! String
                if result.status == "OK" {
                    print("OK userinfo= \(result.userinfo as! String)")
                    DaiFileManager.document["/Audio/"+self.audioFileName].setAttr("C_ReportID", value: result.userinfo as! String)
                    //btnCopyReportURL.hidden = false
                }
                PKNotification.toast(result.message)
                // Remove everything
                //self.removeAllOverlays()
                // Don't forget to unblock!
                SwiftOverlays.removeAllBlockingOverlays()
                
            }
            
            
            
        }
    }
    
    
    func cleanup() {
        timeTimer?.invalidate()
        print("do clean up")
        if let recorder = recorder{
            print("do record cleanup")
            if recorder.recording {
                print("do recorder stop")
                recorder.stop()
                recorder.deleteRecording()
                print("do AudioKit stop")
                AudioKit.stop()
            }
        }
        
        if let player = player {
            player.stop()
            self.player = nil
        }
    }
    
    
    
    func refreshControls(sender: AnyObject) {
        print ("update controls\(btn_Record.state)")
        
        if (sender as! NSObject == btn_Record){
            if let recorder = recorder{
                //btn_Play.enabled = !recorder.recording
                if recorder.recording {
                    //点录音开始/完成按钮后 录音中状态
                    btn_pause.hidden = false
                    btn_pause.enabled = true
                    btn_pause.setTitle("录音暂停", forState: UIControlState.Normal)
                    btn_pause.setImage(UIImage(named:"btn_record_pause"), forState: UIControlState.Normal)
                    btn_pause.titleLabel?.hidden = true
                    //btn_pause.backgroundColor = UIColor.orangeColor()
                    
                    btn_Record.enabled = true
                    btn_Record.setTitle("录音完成", forState: UIControlState.Normal)
                    
                    btn_Record.setImage(image_record_stop,forState:UIControlState.Normal)
                    
                    //imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal
                    btn_Record.titleLabel?.hidden = true
                    
                    //btn_Record.backgroundColor = UIColor.redColor()
                    
                    btn_Play.hidden = true
                    btn_Play.enabled = false
                    btn_Play.setTitle("播  放", forState: UIControlState.Normal)
                    btn_Play.setImage(UIImage(named:"btn_play_play"),forState:UIControlState.Normal)
                    btn_Play.titleLabel?.hidden = true
                    //btn_Play.backgroundColor = UIColor.grayColor()
                }else{
                    //点录音开始/完成铵扭后 录音停止状态
                    btn_pause.hidden = true
                    /*
                     btn_pause.enabled = false
                     btn_pause.setTitle("暂停录音", forState: UIControlState.Normal)
                     btn_pause.backgroundColor = UIColor.orangeColor()
                     */
                    btn_Play.hidden = false
                    btn_Play.enabled = true
                    btn_Play.setImage(UIImage(named:"btn_play_play"),forState:UIControlState.Normal)
                    btn_Play.titleLabel?.hidden = true
                    btn_Play.setTitle("播  放", forState: UIControlState.Normal)
                    //btn_Play.backgroundColor = self.recordercolor
                    
                    btn_Record.enabled = true
                    btn_Record.setImage(image_record_record,forState:UIControlState.Normal)
                    btn_Record.titleLabel?.hidden = true
                    btn_Record.setTitle("录音开始", forState: UIControlState.Normal)
                    //btn_Record.backgroundColor = self.recordercolor
                    //录音停止时直接弹出信息框，可以保存并发布
                    saveAudio(sender)
                }
                
            }else{
                print("recorder is nil")
            }
        }else if (sender as! NSObject == btn_Play){
            
            if let player = player{
                
                if player.playing{
                    //按播放/停止按钮  播放中
                    btn_Play.setTitle("停  止", forState: UIControlState.Normal)
                    btn_Play.setImage(UIImage(named:"btn_play_stop"),forState:UIControlState.Normal)
                    btn_Play.titleLabel?.hidden = true
                    //btn_Play.backgroundColor = UIColor.redColor()
                    
                    btn_Record.enabled = false
                    //btn_Record.backgroundColor = UIColor.grayColor()
                    
                    btn_pause.hidden = true
                    /*
                     btn_pause.enabled = false
                     btn_pause.backgroundColor = UIColor.grayColor()
                     */
                }else{
                    //按播放/停止按钮后 播放停止
                    btn_Play.enabled = true
                    btn_Play.setTitle("播  放", forState: UIControlState.Normal)
                    btn_Play.setImage(UIImage(named:"btn_play_play"),forState:UIControlState.Normal)
                    btn_Play.titleLabel?.hidden = true
                    //btn_Play.backgroundColor = self.recordercolor
                    
                    ///保持原状态
                    btn_Record.enabled = true
                    //btn_Record.backgroundColor = self.recordercolor
                    
                    //btn_pause.hidden = false //保持原状态
                    btn_pause.enabled = true
                    btn_pause.setTitle("录音继续", forState: UIControlState.Normal)
                    btn_pause.setImage(UIImage(named:"btn_record_continue"), forState: UIControlState.Normal)
                    btn_pause.titleLabel?.hidden = true
                    //btn_pause.backgroundColor = UIColor.orangeColor()
                    
                }
            }else{
                
                print("player is nil")
            }
            
        }else if (sender as! NSObject == btn_pause){
            //按下 录音暂停/继续 按钮后  暂停状态
            print(sender.tag)
            if sender.currentTitle == "录音暂停" {
                btn_pause.hidden = false
                btn_pause.enabled = true
                btn_pause.setTitle("录音继续", forState: UIControlState.Normal)
                //btn_pause.backgroundColor = UIColor.orangeColor()
                btn_pause.setImage(UIImage(named:"btn_record_continue"), forState: UIControlState.Normal)
                btn_pause.titleLabel?.hidden = true
                
                btn_Record.enabled = true
                btn_Record.setTitle("录音完成", forState: UIControlState.Normal)
                //btn_Record.backgroundColor = UIColor.redColor()
                
                btn_Record.setImage(image_record_stop, forState: UIControlState.Normal)
                btn_Record.titleLabel?.hidden = true                
                btn_Play.hidden = true
                btn_Play.enabled = false
                btn_Play.setTitle("播  放", forState: UIControlState.Normal)
                //btn_Play.backgroundColor = UIColor.grayColor()
                btn_Play.setImage(UIImage(named:"btn_play_play"), forState: UIControlState.Normal)
                btn_Play.titleLabel?.hidden = true
                
                
            }else if sender.currentTitle == "录音继续" {
                btn_pause.hidden = false
                btn_pause.enabled = true
                btn_pause.setTitle("录音暂停", forState: UIControlState.Normal)
                //btn_pause.backgroundColor = UIColor.orangeColor()
                btn_pause.setImage(UIImage(named:"btn_record_pause"), forState: UIControlState.Normal)
                btn_pause.titleLabel?.hidden = true
                
                
                btn_Record.enabled = true
                btn_Record.setTitle("录音完成", forState: UIControlState.Normal)
                //btn_Record.backgroundColor = UIColor.redColor()
                
                btn_Record.setImage(image_record_stop, forState: UIControlState.Normal)
                btn_Record.titleLabel?.hidden = true
                
                btn_Play.hidden = true
                btn_Play.enabled = false
                btn_Play.setTitle("播  放", forState: UIControlState.Normal)
                //btn_Play.backgroundColor = UIColor.grayColor()
                btn_Play.setImage(UIImage(named:"btn_play_play"), forState: UIControlState.Normal)
                btn_Play.titleLabel?.hidden = true                
            }
        }
        
    }
    
    
    // MARK: Time Label
    
    func updateTimeLabel(timer: NSTimer) {
        var ti:NSInteger = 0
        if ((recorder?.recording) == true) {
            ti = NSInteger(recorder!.currentTime)
        }else if ((self.player?.playing) == true){
            ti = NSInteger(self.player!.currentTime)
        }
        //var ms = Int((interval % 1) * 1000)
        
        let sec = ti % 60
        let min = (ti / 60) % 60
        let hour = (ti / 3600)
        
        timeLabel.text = NSString(format: "%02d:%02d:%02d",hour, min, sec) as String
        print (timeLabel.text)
    }
    
    
    // MARK: Playback Delegate
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        //self.player = nil
        refreshControls(btn_Play)
    }
    
    @IBAction func act_Record(sender: AnyObject) {
        
        print("act_record \(sender.currentTitle)")
        timeTimer?.invalidate()
        //print("sender =\(sender.enabled)")
        
        
        
        if let recorder = recorder{
            if sender.currentTitle == "录音完成" {
                print("set stop")
                recorder.stop()
                AudioKit.stop()
                btn_Save.enabled = true
            }else if sender.currentTitle == "录音开始"{
                print("set recording")
                timeLabel.text = "00:00:00"
                timeTimer = NSTimer.scheduledTimerWithTimeInterval(0.0167, target: self, selector: "updateTimeLabel:", userInfo: nil, repeats: true)
                //recorder.deleteRecording()
                //recorder.prepareToRecord()
                recorder.record()
                AudioKit.start()
                btn_Save.enabled = false
            }else{
                //刚进来时 title是空的 只能点录音键
                print("do nil")
                print("set recording")
                timeLabel.text = "00:00:00"
                timeTimer = NSTimer.scheduledTimerWithTimeInterval(0.0167, target: self, selector: "updateTimeLabel:", userInfo: nil, repeats: true)
                //recorder.deleteRecording()
                //recorder.prepareToRecord()
                recorder.record()
                AudioKit.start()
                btn_Save.enabled = false
            }
        }else{
            print(" no recorder object")
        }
        refreshControls(sender)
    }
    
    @IBAction func act_Pause(sender: AnyObject) {
        print(sender.currentTitle)
        if sender.currentTitle == "录音暂停" {
            print("pause at \(recorder!.currentTime)")
            self.timeinterval = recorder!.currentTime
            timeTimer?.invalidate()
            recorder?.pause()
            //recorder?.stop()
            AudioKit.stop()
            
        }else if sender.currentTitle == "录音继续"{
            print("re record at \(self.timeinterval)")
            //recorder?.recordAtTime(self.timeinterval!)
            timeTimer = NSTimer.scheduledTimerWithTimeInterval(0.0167, target: self, selector: "updateTimeLabel:", userInfo: nil, repeats: true)
            recorder?.record()
            AudioKit.start()
        }
        refreshControls(sender)
    }
    @IBAction func act_Play(sender: AnyObject) {
        //print(self.player)
        timeTimer?.invalidate()
        self.player = nil
        if self.player == nil{
            print(" create player object")
            do {
                try self.player = AVAudioPlayer(contentsOfURL: outputURL)
            }
            catch let error as NSError {
                print("player init error\(error)")
            }
            player?.delegate = self
        }
        
        if let player = self.player {
            print("\(sender.currentTitle) \(player.duration)")
            if sender.currentTitle == "播  放"{
                timeTimer = NSTimer.scheduledTimerWithTimeInterval(0.0167, target: self, selector: "updateTimeLabel:", userInfo: nil, repeats: true)
                player.play()
                
            }else if sender.currentTitle == "停  止"{
                player.stop()
                
            }
            refreshControls(sender)
            
        }else{
            print("player no object")
        }
        
    }
    func userClick(sender: UITapGestureRecognizer) {
        
        
        //let myLabel = view.viewWithTag(sender.view!.tag) as! UILabel
        print("click lable")
    }
    func tapLabel1(){
        
        print("tap the label 1")
        
    }
    func clickbtn(sender:UIButton)
    {
        print("点击事件\(sender.currentTitle)")
        print("背景色\(sender.backgroundColor)")
        
        /*
        if(sender.backgroundColor == nil){
            sender.backgroundColor = UIColor.redColor()
            sender.layer.borderWidth = 0
            sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            
            if(sender.currentTitle != "公开"){
                but1.backgroundColor = nil
                but1.layer.borderWidth = 1
                but1.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
            }
            
        }else{
            sender.backgroundColor = nil
            sender.layer.borderWidth = 1
            sender.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
            
        }
        */
        if(sender.backgroundColor == nil){
            sender.backgroundColor = UIColor.redColor()
            sender.layer.borderWidth = 0
            sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            
            //公开选中时，全选所有按钮
            if(sender.currentTitle == "公开"){
                for item1 in self.butlist {     
                    item1.backgroundColor = UIColor.redColor()
                    item1.layer.borderWidth = 0
                    item1.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                } 
            }
            
        }else{
            sender.backgroundColor = nil
            sender.layer.borderWidth = 1
            sender.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
            
            //公开非选中时，非选所有按钮
            if(sender.currentTitle == "公开"){
                for item1 in self.butlist {     
                    item1.backgroundColor = nil
                    item1.layer.borderWidth = 1
                    item1.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
                } 
            }else{
                but1.backgroundColor = nil
                but1.layer.borderWidth = 1
                but1.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
                
            }
            
        }

        
        
    }
}