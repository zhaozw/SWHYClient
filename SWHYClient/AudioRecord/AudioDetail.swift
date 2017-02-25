//
//  AudioDetail.swift
//  SWHYClient_DEV
//
//  Created by sunny on 8/7/16.
//  Copyright © 2016 DY-INFO. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class AudioDetail: UIViewController,UITextFieldDelegate,UITextViewDelegate,AVAudioPlayerDelegate  {
    
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDesc: UITextView!
    @IBOutlet weak var lblFileName: UILabel!
    
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playTimeLabel: UILabel!
    @IBOutlet weak var allTimeLabel: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    @IBOutlet weak var uploadButton: MKButton!
    @IBOutlet weak var btnCopyReportURL: UIButton!
    
    @IBOutlet weak var lblDuration: MKLabel!
    
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    @IBOutlet weak var btn5: UIButton!
    
    var butlist:[UIButton]!
    
    
    
    //var audioPlayer:AVPlayerViewController = AVPlayerViewController()
    var player: AVAudioPlayer? = AVAudioPlayer()
    var timer:NSTimer?
    var audioFileName:String = ""
    
    var placeholderLabel:UILabel!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    
    convenience init() {
        //print(" override init =======begin====")
        self.init(nibName: "AudioDetail", bundle: nil)
        //print("over ride init =======after=======")
        //self.init(nibName: "LaunchScreen", bundle: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear")
        timer?.invalidate()
        timer = nil
        print("time end")
        if let player = player {
            player.stop()
            self.player = nil
            print("player set to nil")
        }
    } 
    
    
    
    
    func sliderDidchange(slider:UISlider){
        print(slider.value)
        //self.player?.playAtTime(<#T##time: NSTimeInterval##NSTimeInterval#>)
        self.player!.currentTime = NSTimeInterval(slider.value) //15.0  //slider.value as NSTimeInterval
        self.updateTime()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //self.contentView.frame.origin.y = 30
        //self.scrollview.scrollEnabled = true
        self.audioFileName =  Message.shared.audioFileName
        self.title = "微录音"
        
        
        self.lblFileName.text = self.audioFileName
        print(DaiFileManager.document["/Audio/"+self.audioFileName].attrs)
        
        //progressSlider.setMinimumTrackImage(UIImage(named: "player_slider_playback_left"), forState: UIControlState.Normal)
        //progressSlider.setMaximumTrackImage(UIImage(named: "player_slider_playback_right"), forState: UIControlState.Normal)
        //progressSlider.setThumbImage(UIImage(named: "player_slider_playback_thumb"), forState: UIControlState.Normal)
        
        
        
        progressSlider.continuous = true //false  //滑块滑动停止后才触发ValueChanged事件
        progressSlider.addTarget(self,action:"sliderDidchange:", forControlEvents:UIControlEvents.ValueChanged)
        
        print(DaiFileManager.document["/Audio/"+self.audioFileName])
        self.txtTitle.text = DaiFileManager.document["/Audio/"+self.audioFileName].getAttr("C_Title")
        self.txtDesc.text = DaiFileManager.document["/Audio/"+self.audioFileName].getAttr("C_Desc")
        self.allTimeLabel.text = DaiFileManager.document["/Audio/"+self.audioFileName].getAttr("C_Duration")
        self.lblDuration.text = self.allTimeLabel.text
        
        //progressSlider.minimumValue=0  //最小值
        
        //progressSlider.value=0.5  //当前默认值
        
        let fileSize = DaiFileManager.document["/Audio/"+self.audioFileName].attrs.fileSize() 
        //let fileSize = fileSizeNumber
        var sizeMB = Double(fileSize / 1024)
        sizeMB = Double(sizeMB / 1024)
        print(String(format: "%.2f", sizeMB) + " MB")
        
        
        self.lblSize.text = String(format: "%.2f", sizeMB) + " MB"
        
        
        self.txtTitle.returnKeyType = UIReturnKeyType.Done      
        self.txtTitle.delegate = self
        
        
        
        self.txtDesc.returnKeyType = UIReturnKeyType.Default
        self.txtDesc.delegate = self
        
        self.placeholderLabel = UILabel.init() // placeholderLabel是全局属性  
        self.placeholderLabel.frame = CGRectMake(5 , 5, 100, 20)  
        self.placeholderLabel.font = UIFont.systemFontOfSize(14)  
        self.placeholderLabel.text = "摘要"  
        txtDesc.addSubview(self.placeholderLabel)  
        //self.placeholderLabel.textColor = UIColor.init(colorLiteralRed: 72/256, green: 82/256, blue: 93/256, alpha: 1)  
        self.placeholderLabel.textColor = UIColor.lightGrayColor()  
        
        let auth = DaiFileManager.document["/Audio/"+self.audioFileName].getAttr("C_Auth")
        self.butlist = [btn1,btn2,btn3,btn4,btn5]
        for but in self.butlist {     
            but.titleLabel!.font = UIFont.systemFontOfSize(14)
            but.layer.cornerRadius = 4
            but.layer.borderColor = UIColor.lightGrayColor().CGColor  
            but.layer.borderWidth = 1
            but.setTitleColor(UIColor.lightGrayColor(), forState: .Normal) 
            //but.contentEdgeInsets = UIEdgeInsetMake(10, 10, 10, 10)
            but.contentEdgeInsets = UIEdgeInsetsMake(2,2,2,2) 
            but.addTarget(self, action: "clickbtn:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        if auth.componentsSeparatedByString("公开").count > 1 { 
            btn1.backgroundColor = UIColor.redColor()
            btn1.layer.borderWidth = 0
            btn1.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        }
        if auth.componentsSeparatedByString("研究所").count > 1 {  
            btn2.backgroundColor = UIColor.redColor()
            btn2.layer.borderWidth = 0
            btn2.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        } 
        if auth.componentsSeparatedByString("机构客户").count > 1 {  
            btn3.backgroundColor = UIColor.redColor()
            btn3.layer.borderWidth = 0
            btn3.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        } 
        if auth.componentsSeparatedByString("投顾").count > 1 {  
            btn4.backgroundColor = UIColor.redColor()
            btn4.layer.borderWidth = 0
            btn4.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        }         
        if auth.componentsSeparatedByString("认证客户").count > 1 {  
            btn5.backgroundColor = UIColor.redColor()
            btn5.layer.borderWidth = 0
            btn5.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        }
        
        
        
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "textDidEndEditing", name: UITextViewTextDidEndEditingNotification, object: nil)
    }
    
    
    func clickbtn(sender:UIButton)
    {
        print("点击事件\(sender.currentTitle)")
        print("背景色\(sender.backgroundColor)")
        
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
                btn1.backgroundColor = nil
                btn1.layer.borderWidth = 1
                btn1.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
            
            }
            
        }
        
        
        
        var authtext:String = ""
        for item1 in self.butlist {     
            if(item1.backgroundColor != nil){
                authtext = authtext + item1.currentTitle! + ","
            }
        }
        DaiFileManager.document["/Audio/"+self.audioFileName].setAttr("C_Auth", value: authtext)
        
        
        
    }

    
    override func viewWillAppear(animated: Bool) {
        print("viewwill appear")
        super.viewWillAppear(animated)
        //self.title = Message.shared.curMenuItem.name
        let backitem = UIBarButtonItem(title: Config.UI.PreNavItem, style: UIBarButtonItemStyle.Plain, target: self, action: "returnNavView")
        self.navigationItem.leftBarButtonItem = backitem
        setMyCurrentSong()
        print("view reportid\(DaiFileManager.document["/Audio/"+self.audioFileName].getAttr("C_ReportID"))")
        if DaiFileManager.document["/Audio/"+self.audioFileName].getAttr("C_ReportID") != ""{
            btnCopyReportURL.hidden = false
            
        }else{
            btnCopyReportURL.hidden = true
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch let error as NSError {
            NSLog("Error: \(error)")
        }
        
        
        if txtDesc.text == "" {
            self.placeholderLabel.hidden = false // 显示
        }else{
            self.placeholderLabel.hidden = true // 隐藏 
        }
        
        //btnCopyReportURL
        //let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        //let webViewMenuViewController = storyboard.instantiateViewControllerWithIdentifier("WebViewMenuViewController") as! WebViewMenuViewController
        //self.slideMenuController()?.changeRightViewController(webViewMenuViewController, closeRight: true)
        //self.setNavigationBarItem()
        
    }
    @IBAction func view2_click(sender: AnyObject) {
        txtTitle.resignFirstResponder()
        txtDesc.resignFirstResponder()
    }
    
    @IBAction func view3_click(sender: AnyObject) {
        txtTitle.resignFirstResponder()
        txtDesc.resignFirstResponder()
    }
    
    @IBAction func view4_click(sender: AnyObject) {
        txtTitle.resignFirstResponder()
        txtDesc.resignFirstResponder()
    }
    
    @IBAction func view1_click(sender: AnyObject) {
        print(sender)
        txtTitle.resignFirstResponder()
        txtDesc.resignFirstResponder()
    }
    @IBAction func viewClick(sender: AnyObject) {
        txtTitle.resignFirstResponder()
        txtDesc.resignFirstResponder()
    }
    
    func textDidEndEditing()
    {
        print("结束输入...")
    }
    
    func returnNavView(){
        print("click return button")
        self.navigationController?.popViewControllerAnimated(true)
        
        //let audioRecorderViewController:AudioRecorder = AudioRecorder()
        //self.slideMenuController()?.changeMainViewController(UINavigationController(rootViewController: audioRecorderViewController), close: true)
    }
    
    func setMyCurrentSong() {
        //currentSong = curSong
        //currentIndex = tableData.indexOfObject(curSong)
        //NSLog("%d",currentIndex)
        //photo.image = getImageWithUrl(currentSong.picture)
        //backgroundImageView.image = photo.image
        //titleLabel.text = currentSong.title as String
        // artistLabel.text = currentSong.artist as String
        playButton.selected = false
        playTimeLabel.text = "00:00:00"
        self.progressSlider.value = 0.0
        //self.rotationAnimation()
        //self.audioPlayer.
        
        do {
            //print(DaiFileManager.document["/Audio/"+self.audioFileName].path)
            try player = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: DaiFileManager.document["/Audio/"+self.audioFileName].path))
            
            //progressSlider.maximumValue = Float((player?.duration)!)  //最大值
            //print(progressSlider.maximumValue)
            //print(player?.duration)
        }
        catch let error as NSError {
            NSLog("error: \(error)")
        }
        
        //let all:Int=Int((self.player!.duration))//共多少秒
        //let m:Int=all % 60//秒
        //let f:Int=Int(all/60)//分
        
        //var time=NSString(format:"%02d:%02d",f,m)
        //print(time)
        //self.allTimeLabel.text = time as String
        
        
        player?.delegate = self
        //player?.play()
        
        //self.audioPlayer.contentURL=NSURL(string:currentSong.url as String)
        //timer?.invalidate()
        //timer=NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "updateTime", userInfo: nil, repeats: true)
        //playButton.setImage(UIImage(named: "player_btn_play_normal.png"), forState: UIControlState.Normal)
        
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        // 重新开启定时器
        if flag{
            print("play end")
            timer?.invalidate()
            print("timer end")
            playButton.setImage(UIImage(named: "player_btn_play_normal"), forState: UIControlState.Normal)
            playButton.selected = !playButton.selected
        }
    }
    
    //播放
    @IBAction func playButtonClick(sender: UIButton) {
        if sender.selected {
            //暂停播放
            self.player!.pause()
            timer?.invalidate()
            print("timer pause")
            //pauseLayer(photo.layer)
            playButton.setImage(UIImage(named: "player_btn_play_normal"), forState: UIControlState.Normal)
            
        }else{
            //开始/继续播放
            self.player!.play()
            timer?.invalidate()
            timer=NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "updateTime", userInfo: nil, repeats: true)
            
            playButton.setImage(UIImage(named: "player_btn_pause_highlight.png"), forState: UIControlState.Normal)
        }
        sender.selected = !sender.selected
    }
    
    @IBAction func doUpload(sender: AnyObject) {
        //登陆成功后，上传日志
        if(self.txtTitle.text == "" || self.txtDesc.text == ""){
            PKNotification.toast("标题和摘要不允许为空!")
        }else{
            let text = "请稍候，正在发布中..."
            //self.showWaitOverlayWithText(text)
            SwiftOverlays.showBlockingWaitOverlayWithText(text)
            
            let audiourl = DaiFileManager.document["/Audio/"+self.audioFileName].getAttr("C_URL")
            print(audiourl)
            if audiourl == "" {
                DaiFileManager.document["/Audio/"+self.audioFileName].setAttr("C_Title", value: self.txtTitle.text!)
                DaiFileManager.document["/Audio/"+self.audioFileName].setAttr("C_Desc", value: self.txtDesc.text!)
                print("上传文件开始 --------------")
                let filePath = DaiFileManager.document["/Audio/"+self.audioFileName].path
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "HandleNetworkResult:", name: Config.RequestTag.PostUploadAudioFile, object: nil)
                NetworkEngine.sharedInstance.postUploadFile(Config.URL.PostUploadAudioFile, filePath: filePath, tag: Config.RequestTag.PostUploadAudioFile)
            }else{
                print("直接发布report")
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "HandleNetworkResult:", name: Config.RequestTag.GetWeiXinToken, object: nil)
                NetworkEngine.sharedInstance.addRequestWithUrlString(Config.URL.GetWeiXinToken, tag: Config.RequestTag.GetWeiXinToken, useCache: false) 
            }
        }
        
    }
    
    func HandleNetworkResult(notify:NSNotification)
    {
        let result:Result = notify.valueForKey("object") as! Result
        
        print(result)
        //NSNotificationCenter.defaultCenter().removeObserver(self, name: Config.RequestTag.PostUploadFile, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: result.tag, object: nil)
        
        if result.status == "Error" {
            print("-------post  error-------------")
            PKNotification.toast(result.message)
            SwiftOverlays.removeAllBlockingOverlays()
            
        }else if result.status=="OK"{
            if result.tag == Config.RequestTag.PostUploadAudioFile {
                //Audio文件保留上传的URL地址 
                DaiFileManager.document["/Audio/"+self.audioFileName].setAttr("C_URL", value: Config.URL.AudioBaseURL + Message.shared.postUserName + "_" + self.audioFileName)
                //PKNotification.toast(result.message)
                //上传成功的话 就获取weixin token
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "HandleNetworkResult:", name: Config.RequestTag.GetWeiXinToken, object: nil)
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
                //let authorid = "00190"
                
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
                //let json = "{\"title\":\"\(title)\",\"content\":\"\(content)\",\"audiourl\":\"\(audiourl)\",\"authorid\":\"\(authorid)\"}"
                //let json = "{title:\"\(title)\",content:\"\(content)\",audiourl:\"\(audiourl)\",authorid:\"\(authorid)\"}"
                
                print(authkey)
                //let json = "{\"title\":\"\(title)\",\"content\":\"\(content)\",\"audiourl\":\"\(audiourl)\",\"authorid\":\"\(authorid)\"}"
                let json = "{title:\"\(title)\",content:\"\(content)\",audiourl:\"\(audiourl)\",authorid:\"\(authorid)\",cardpermission:\"\(authkey)\"}"
                print(json)
                
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "HandleNetworkResult:", name: Config.RequestTag.PostAudioTopic, object: nil)
                //tk001hkieder25091
                
                print(Config.URL.PostAudioTopic+result.message)
                NetworkEngine.sharedInstance.postRequestWithUrlString(Config.URL.PostAudioTopic+result.message, postData:json,tag:Config.RequestTag.PostAudioTopic)
                
            }else if result.tag == Config.RequestTag.PostAudioTopic{
                //result.userinfo as! String
                if result.status == "OK" {
                    print("OK userinfo= \(result.userinfo as! String)")
                    DaiFileManager.document["/Audio/"+self.audioFileName].setAttr("C_ReportID", value: result.userinfo as! String)
                    btnCopyReportURL.hidden = false
                }
                PKNotification.toast(result.message)
                SwiftOverlays.removeAllBlockingOverlays()
                
            }
            
            
            
        }
        
    }
    
    
    func textFieldShouldReturn(textField:UITextField) -> Bool
    {
        //收起键盘
        textField.resignFirstResponder()
        //打印出文本框中的值
        print(textField.text)
        return true;
    }
    /*
     func textViewShouldReturn(textView: UITextView) -> Bool
     {
     //收起键盘
     textView.resignFirstResponder()
     //打印出文本框中的值
     print(textView.text)
     return true;
     }
     */
    func textFieldDidEndEditing(textField: UITextField){
        
        print("end editing \(textField.text)")
        if (textField == self.txtTitle){
            print("get obj field")
            DaiFileManager.document["/Audio/"+self.audioFileName].setAttr("C_Title", value: textField.text!)
        }
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {  
        print("textViewShouldBeginEditing")  
        if textView == txtDesc {
            self.placeholderLabel.hidden = true // 隐藏  
        }
        return true  
    }  
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView == txtDesc {
            DaiFileManager.document["/Audio/"+self.audioFileName].setAttr("C_Desc", value: textView.text)
            if textView.text.isEmpty {  
                self.placeholderLabel.hidden = false  // 显示  
            }  
            else{  
                self.placeholderLabel.hidden = true  // 隐藏  
            }  
        }
        print("textViewDidEndEditing")  
    }  
    
    /*
     func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
     if(text == "\n") {
     textView.resignFirstResponder()
     return false
     }
     return true
     }
     */
    //更新播放时间
    func updateTime(){
        
        var c=self.player!.currentTime
        print("c = \(c) duration =\(self.player?.duration)")
        // audioPlayer.endPlaybackTime
        if c>0.0 {
            //let t = CMTimeGetSeconds(self.player!.duration);
            let t=self.player!.duration
            let p:CFloat=CFloat(c/t)
            //progressSlider.value=p;
            progressSlider.value=Float(c);
            progressSlider.maximumValue = Float(t)
            let all:Int=Int(c)//共多少秒
            let m:Int=all % 60//秒
            let f:Int=Int(all/60)//分
            let hour = f / 60
            var time=NSString(format:"%02d:%02d:%02d",hour,f,m)
            
            playTimeLabel.text=time as String
        }
    }
    @IBAction func actCopyToClipBoard(sender: AnyObject) {
        var pasteBoard = UIPasteboard.generalPasteboard()
        pasteBoard.string = Config.URL.ViewWeiXinReport + DaiFileManager.document["/Audio/"+self.audioFileName].getAttr("C_ReportID")
        PKNotification.toast("云聚报告地址已拷贝")
    }
    
}
