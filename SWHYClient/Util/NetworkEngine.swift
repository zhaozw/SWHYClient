//
//  NetworkEngin.swift
//  NetWorkTest
//
//  Created by sunny on 3/18/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//

import Foundation
import UIKit

class Result {
    var status:String
    var message:String
    var userinfo:AnyObject
    var tag:String
    
    init(status:String,message:String,userinfo:AnyObject,tag:String){
        self.status = status
        self.message = message
        self.userinfo = userinfo
        self.tag = tag
    }
    
}

class NetworkEngine:NSObject, NSURLSessionDelegate {
    
    private var configuration:NSURLSessionConfiguration = NSURLSessionConfiguration()
    private var session = NSURLSession()
    private var alive = false
    private var success_auth = 0
    
    private var serverlist:Dictionary<String,Bool> = Dictionary()
    
    class var sharedInstance: NetworkEngine {
        let configuration:NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 120  //超时设置为300秒
        configuration.timeoutIntervalForResource = 120 
        print(configuration.timeoutIntervalForRequest) //= 15 //连接超时时间
        Inner.instance.session = NSURLSession(configuration: configuration,delegate: Inner.instance,delegateQueue:NSOperationQueue.mainQueue())
        
        return Inner.instance
    }
    
    struct Inner {
        
        static let instance: NetworkEngine = NetworkEngine()
    }
    override init(){
        //self.cache = Cache<NSString>(name: "awesomeCache", directory: "cache")
        super.init()
        
    }
    //0EB020F9-F3DA-4585-8A24-57212DAEE985
    func postRequestWithUrlString(url:String,postData:String,tag:String){
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.setValue("application/text; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        //request.setValue("application/text", forHTTPHeaderField: "Content-Type")
        //request.addValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = postData.dataUsingEncoding(NSUTF8StringEncoding)               
        request.HTTPMethod = "POST"
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    print("response was not 200: \(response)")
                    return
                }
            }
            if (error != nil) {
                print("error submitting request: \(error)")
                return
            }
            
            // handle the data of the successful response here
            // handle the data of the successful response here
            let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(Config.Encoding.GB2312))
            let res:String = NSString(data: data!, encoding: enc)! as String
            
            
        }
        task.resume()
        
        
        
    }
    
    func postLogList(url:String,tag:String){
        
        
        if let itemlist:NSArray = DBAdapter.shared.queryAccessLogList("sync <> ?", paralist: ["Y"]) {
            /*
             [{"ID":"2","UserID":"shenyd","Time":"2015-04-29+20:48:20","ModuleID":"M9A","OnLine":"true","ModuleName":"测试Jquery","Type":"OpenModule"},{"ID":"3","UserID":"shenyd","Time":"2015-04-29+20:48:47","ModuleID":"M01","OnLine":"true","ModuleName":"所内通讯录","Type":"OpenModule"},{"ID":"4","UserID":"shenyd","Time":"2015-04-29+21:53:46","ModuleID":"M22","OnLine":"true","ModuleName":"内网待办事宜","Type":"OpenModule"},{"ID":"5","UserID":"shenyd","Time":"2015-04-29+21:54:42","ModuleID":"M01","OnLine":"true","ModuleName":"所内通讯录","Type":"OpenModule"},{"ID":"6","UserID":"shenyd","Time":"2015-05-03+13:33:41","ModuleID":"","OnLine":"true","ModuleName":"","Type":"Login"},{"ID":"7","UserID":"shenyd","Time":"2015-05-03+13:33:44","ModuleID":"M01","OnLine":"true","ModuleName":"所内通讯录","Type":"OpenModule"}]
             */
            
            var json:String = ""
            for var i:Int=0;i<itemlist.count; i++ {
                
                let item:AccessLogItem = itemlist[i] as! AccessLogItem
                let timestr = item.time.stringByReplacingOccurrencesOfString(" ", withString: "+")
                json += "{\"ID\":\"\(item.id)\",\"UserID\":\"\(item.userid)\",\"Time\":\"\(timestr)\",\"ModuleID\":\"\(item.moduleid)\",\"ModuleName\":\"\(item.modulename)\",\"Type\":\"\(item.type)\"}"
                
                if i<itemlist.count-1 {
                    json += ","
                }
            }
            json = "&AccessLogs=["+json+"]"
            
            
            var result:String = ""
            let request = NSMutableURLRequest(URL: NSURL(string: url)!)
            request.setValue("application/json; charset=gb2312", forHTTPHeaderField: "Content-Type")
            
            let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(Config.Encoding.GB2312))
            //NSUTF8StringEncoding
            
            //这步是字符串的URLEncode
            let data = json.stringByAddingPercentEscapesUsingEncoding(enc)
            
            
            request.HTTPBody = data!.dataUsingEncoding(enc)             
            request.HTTPMethod = "POST"
            
            //print(request.HTTPBody)
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                data, response, error in
                
                if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode != 200 {
                        print("response was not 200: \(response)")
                        result =  "Error: \(httpResponse.statusCode)"
                        self.dispatchResponse(result,tag: tag)
                        
                    }
                }
                if (error != nil) {
                    print("error submitting request: \(error)")
                    result = "Error: \(error)"
                    self.dispatchResponse(result,tag: tag)
                    
                }
                
                // handle the data of the successful response here
                let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(Config.Encoding.GB2312))
                let res:String = NSString(data: data!, encoding: enc)! as String
                
                print(res)
                if res.componentsSeparatedByString("OK").count > 1 {
                    
                    if (tag == Config.RequestTag.PostAccessLog){
                        
                        let sqlresult = DBAdapter.shared.markAccessLogListSync(itemlist)
                        //println(sqlresult)
                        //let sqlresult = 999
                        
                        self.dispatchResponse("系统已自动同步访问日志:\(String(sqlresult)) 条",tag: tag)
                        
                    }else if (tag != Config.RequestTag.PostAccessLog){
                        
                        
                        
                    }
                    
                }else if res.componentsSeparatedByString("Error").count > 1{
                    
                    result = "Error: 同步访问日志出错)"
                    //println(result)
                    self.dispatchResponse(result,tag: tag)
                }
            }
            task.resume()
            
            
        }
        
    }
    
    //===========同步 客户通讯录日志===============================
    func postCustomerLogList(url:String,tag:String){
        
        //print("同步客户通讯录日志")
        
        if let itemlist:NSArray = DBAdapter.shared.queryCustomerLogList("sync <> ?", paralist: ["Y"]) {
            /*
             [{"CustContactMode":"18616829776","CustContactID":"","Type":"1","Duration":"42","ID":"15","EndTime":"","UserName":"shenyd","StartTime":"2014-11-22+14:55:22","Module":"com.simpleflow.androidtest.PhoneTaskReceiver"},{"CustContactMode":"13641694940","CustContactID":"","Type":"2","Duration":"19","ID":"16","EndTime":"","UserName":"shenyd","StartTime":"2014-11-22+16:12:48","Module":"com.simpleflow.androidtest.PhoneTaskReceiver"}]
             */
            
            var json:String = ""
            for var i:Int=0;i<itemlist.count; i++ {
                
                let item:CustomerLogItem = itemlist[i] as! CustomerLogItem
                let timestart = item.startdatetime.stringByReplacingOccurrencesOfString(" ", withString: "+")
                let timeend = item.enddatetime.stringByReplacingOccurrencesOfString(" ", withString: "+")
                json += "{\"CustContactMode\":\"\(item.phonenumber)\",\"CustContactID\":\"\(item.customerid)\",\"Type\":\"\(item.type)\",\"Duration\":\"\(item.duration)\",\"ID\":\"\(item.id)\",\"EndTime\":\"\(timeend)\",\"UserName\":\"\(item.user)\",\"StartTime\":\"\(timestart)\",\"Module\":\"\(item.module)\"}"
                
                if i<itemlist.count-1 {
                    json += ","
                }
            }
            json = "&CustomerLogs=["+json+"]"
            
            //println(json)
            
            var result:String = ""
            let request = NSMutableURLRequest(URL: NSURL(string: url)!)
            request.setValue("application/json; charset=gb2312", forHTTPHeaderField: "Content-Type")
            
            let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(Config.Encoding.GB2312))
            //NSUTF8StringEncoding
            
            //这步是字符串的URLEncode
            let data = json.stringByAddingPercentEscapesUsingEncoding(enc)
            
            
            request.HTTPBody = data!.dataUsingEncoding(enc)             
            request.HTTPMethod = "POST"
            
            //
            //print(request.HTTPBody, terminator: "")
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                data, response, error in
                
                if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode != 200 {
                        //print("response was not 200: \(response)")
                        result =  "Error: \(httpResponse.statusCode)"
                        self.dispatchResponse(result,tag: tag)
                        
                    }
                }
                if (error != nil) {
                    print("error submitting request: \(error)")
                    result = "Error: \(error)"
                    self.dispatchResponse(result,tag: tag)
                    
                }
                
                // handle the data of the successful response here
                let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(Config.Encoding.GB2312))
                let res:String = NSString(data: data!, encoding: enc)! as String
                
                //print(res)
                if res.componentsSeparatedByString("OK").count > 1 {
                    
                    if (tag == Config.RequestTag.PostCustomerLog){
                        
                        let sqlresult = DBAdapter.shared.markCustomerLogListSync(itemlist)
                        //println(sqlresult)
                        //let sqlresult = 999
                        
                        self.dispatchResponse("系统已自动同步客户通讯录日志:\(String(sqlresult)) 条",tag: tag)
                        
                    }else if (tag != Config.RequestTag.PostCustomerLog){
                        
                    }
                    
                }else if res.componentsSeparatedByString("Error").count > 1{
                    
                    result = "Error: 同步客户通讯录日志出错)"
                    //println(result)
                    self.dispatchResponse(result,tag: tag)
                }
            }
            task.resume()
            
        }
        
    }
    
    //===========上传文件===============================
    func postUploadFile(url:String,filePath:String,tag:String){
        print(url)
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        //let multiPartMime = MultiPartMime(dict: ["fulFile": MultiPartPart.StringWrapper(filename), "file": MultiPartPart.PNGImage(img, filename)])
        
        let multiPartMime = MultiPartMime(dict: ["File": MultiPartPart.File(filePath),"UserName":MultiPartPart.StringWrapper(Message.shared.postUserName)])
        
        //let multiPartMime = MultiPartMime(dict: ["UserName":MultiPartPart.StringWrapper(Message.shared.postUserName)])
        
        request.HTTPBody = multiPartMime.multiPartData           
        request.HTTPMethod = "POST"
        
        request.setValue(multiPartMime.contentTypeString, forHTTPHeaderField:"Content-Type")
        //print(request.HTTPBody)
        
        var datastring = String(data: request.HTTPBody!, encoding: NSUTF8StringEncoding)
        
        print(datastring)
        //print(multiPartMime.multiPartData)
        var result:String = ""
        //-------------------
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            print("response =\(response)")
            if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    print("response was not 200: \(response)")
                    result =  "Error: \(httpResponse.statusCode)"
                    self.dispatchResponse(result,tag: tag)
                    
                }
            }
            if (error != nil) {
                print("Error ====\(error!.localizedDescription) ==code=\(error!.code)")
                var errmsg = ""
                if error!.code == -999{
                    //cancelled  用户名密码验证不通过时，取消请求
                    errmsg = "用户名或密码错误"
                }else{
                    errmsg = "网络连接出错，请检查网络或稍后再试"
                }
                
                self.success_auth = 0
                self.alive = false
                //print("request url host = false  \(request.URL?.host!)")
                self.serverlist.updateValue(false, forKey: request.URL?.host!  ?? "AnyServer")
                let result:Result = Result(status: "Error",message:errmsg,userinfo:error!,tag:tag)
                NSNotificationCenter.defaultCenter().postNotificationName(tag, object: result)          
            }else{
                // handle the data of the successful response here
                //let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(Config.Encoding.GB2312))
                //let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(NSUTF8StringEncoding))
                
                let res:String = NSString(data: data!, encoding: NSUTF8StringEncoding)! as String
                
                print(" res convert =\(res)")
                if res.componentsSeparatedByString("OK").count > 1 {
                    
                    result = "Success: 上传文件成功"
                    print(result)
                    self.dispatchResponse(result,tag: tag)                
                }else if res.componentsSeparatedByString("Error").count > 1{
                    
                    result = "Error: 上传文件出错"
                    print(result)
                    self.dispatchResponse(result,tag: tag)
                }
            }
        }
        print("before resume")
        task.resume()
        
    }
    
    //==========================================================
    
    
    func addRequestWithUrlString(url:String,tag:String,useCache:Bool?){
        let getcache = false
        
        /*
         let cache = Haneke.Shared.dataCache
         
         if tag != Config.RequestTag.DoLogin && useCache == true {
         
         
         cache.fetch(key: url).onSuccess { data in
         println("________get Cache_____________")
         getcache = true
         let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(Config.Encoding.GB2312))
         let res:String = NSString(data: data, encoding: enc)! as String
         self.dispatchResponse(res,tag: tag)
         }
         
         
         }
         */
        //let url1 = "https://github.com"
        let request = NSMutableURLRequest(URL: NSURL(string: url+"&client="+Config.Net.ClientType)!)
        //let request = NSMutableURLRequest(URL: NSURL(string: url1)!)
        //print("url =\(url1)")
        let task = self.session.dataTaskWithRequest(request){(data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if error != nil {
                print("Error ====\(error!.localizedDescription) ==code=\(error!.code)")
                var errmsg = ""
                if error!.code == -999{
                    //cancelled  用户名密码验证不通过时，取消请求
                    errmsg = "用户名或密码错误"
                }else{
                    errmsg = "网络连接出错，请检查网络或稍后再试"
                }
                
                self.success_auth = 0
                self.alive = false
                //print("request url host = false  \(request.URL?.host!)")
                self.serverlist.updateValue(false, forKey: request.URL?.host!  ?? "AnyServer")
                let result:Result = Result(status: "Error",message:errmsg,userinfo:error!,tag:tag)
                NSNotificationCenter.defaultCenter().postNotificationName(tag, object: result)
                
            } else {
                
                //println("--------------set cache---------------")
                
                //cache.set(value: data, key: url)   //原hanekeswift的方法
                //print("request url host = true  \(request.URL?.host!)")
                self.serverlist.updateValue(true, forKey: request.URL?.host! ?? "AnyServer")
                self.alive = true
                if getcache == false {
                    
                    //println("______________get ReS_____________")
                    let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(Config.Encoding.GB2312))
                    let res:String = NSString(data: data!, encoding: enc)! as String
                    //print("______________get ReS_____________\(res)")
                    
                    
                    self.dispatchResponse(res,tag: tag)
                }
                //NSNotificationCenter.defaultCenter().postNotificationName(tag, object: res)
            }
        }
        task.resume()
    }
    
    private func dispatchResponse(res:String,tag:String){
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            //这里写需要大量时间的代码
            //print("dispatch \(res)")
            
            var result:Result
            switch tag{
                
            case Config.RequestTag.DoLogin:
                //println(res)
                //True@@2.0.06@@swinbak.swsresearch.net/Mobile/mobileinterface.nsf/c3d933b0b726ea7c48257dcf002c8a01/$FILE/SwsresearchMobileTest.apk?openelement@@登录成功@@
                
                let tmparr = res.componentsSeparatedByString("@@")
                var userInfo = Dictionary<String, String>()
                userInfo.updateValue(tmparr[0], forKey: "Flag")
                userInfo.updateValue(tmparr[1], forKey: "Version")
                userInfo.updateValue(tmparr[2], forKey: "UpgradeURL")
                userInfo.updateValue(tmparr[3], forKey: "Message")
                
                result = Result(status: "OK",message:"",userinfo:userInfo,tag:tag)
                //NSNotificationCenter.defaultCenter().postNotificationName(tag, object: result)
                
                
            case Config.RequestTag.GetMainMenu:
                let xml = SWXMLHash.parse(res)
                let userInfo = NSMutableArray()
                for elem in xml["entries"]["entry"]{
                    let mainMenuItemBO:MainMenuItemBO = MainMenuItemBO()
                    mainMenuItemBO.name = elem["itemtext"][0].element?.text ?? ""
                    mainMenuItemBO.itemimage = Config.URL.BaseURL + (elem["itemimage"][0].element?.text ?? "")
                    mainMenuItemBO.classname = elem["class"][0].element?.text ?? ""
                    mainMenuItemBO.uri = elem["uri"][0].element?.text ?? ""
                    //println(elem["uri"][0].element?.text ?? "")
                    mainMenuItemBO.id = elem["id"][0].element?.text ?? ""
                    mainMenuItemBO.offline = elem["offl"][0].element?.text ?? ""
                    
                    /*
                     let URL = NSURL(string: Config.URL.BaseURL+mainMenuItemBO.itemimage)!
                     let fetcher = HNKNetworkFetcher< UIImage >(URL: URL)
                     Haneke.Shared.imageCache.fetch(fetcher: fetcher).onSuccess { image in
                     // Do something with image
                     mainMenuItemBO.icon = UIImagePNGRepresentation(image)
                     
                     }
                     */
                    //mainMenuItemBO.initWithDic(dict as NSDictionary)
                    userInfo.addObject(mainMenuItemBO)
                }
                result = Result(status: "OK",message:"",userinfo:userInfo,tag:tag)
                //NSNotificationCenter.defaultCenter().postNotificationName(tag, object: result)   
                
            case Config.RequestTag.GetInnerAddressBook:
                //print("取得所内通讯录在线数据 网络解析 开始 ")
                let xml = SWXMLHash.parse(res)
                let userInfo = NSMutableArray()
                for elem in xml["entries"]["entry"]{
                    let item:InnerAddressItem = InnerAddressItem()
                    item.name = elem["name"][0].element?.text ?? ""
                    item.dept = elem["dept"][0].element?.text ?? ""
                    item.mobile = elem["mobile"][0].element?.text ?? ""
                    item.linetel = elem["linetel"][0].element?.text ?? ""
                    item.empid = elem["empid"][0].element?.text ?? ""
                    item.mobiletelecom = elem["mobiletelecom"][0].element?.text ?? ""
                    item.mobiletelecom1 = elem["mobiletelecom1"][0].element?.text ?? ""
                    item.mobile1 = elem["mobile1"][0].element?.text ?? ""
                    item.othertel = elem["othertel"][0].element?.text ?? ""
                    item.homephone = elem["homephone"][0].element?.text ?? ""
                    item.researchteam = elem["researchteam"][0].element?.text ?? ""
                    item.msn = elem["msn"][0].element?.text ?? ""
                    item.pic = elem["pic"][0].element?.text ?? ""
                    item.query = ""
                    if item.name.isEmpty == false {
                        item.query = item.query + item.name
                    }
                    if item.dept.isEmpty == false {
                        item.query = item.query + item.dept
                    }
                    if item.mobile.isEmpty == false {
                        item.query = item.query + item.mobile
                    }
                    if item.mobiletelecom.isEmpty == false {
                        item.query = item.query + item.mobiletelecom
                    }
                    
                    
                    userInfo.addObject(item)
                }
                result = Result(status: "OK",message:"",userinfo:userInfo,tag:tag)
                //NSNotificationCenter.defaultCenter().postNotificationName(tag, object: result)
                
            case Config.RequestTag.GetInnerAddressBook_Dept:
                let xml = SWXMLHash.parse(res)
                let userInfo = NSMutableArray()
                for elem in xml["entries"]["entry"]{
                    let item:InnerAddressDeptItem = InnerAddressDeptItem()
                    item.name = elem["dept"][0].element?.text ?? ""
                    if item.name != "" {
                        userInfo.addObject(item)
                    }
                    
                }
                result = Result(status: "OK",message:"",userinfo:userInfo,tag:tag)
            //NSNotificationCenter.defaultCenter().postNotificationName(tag, object: result)
            case Config.RequestTag.WebViewPreGet:
                result = Result(status: "OK",message:"",userinfo:NSObject(),tag:tag)
                //NSNotificationCenter.defaultCenter().postNotificationName(tag, object: result)
                
            case Config.RequestTag.PostAccessLog:
                //println("dispatch \(res)  \(tag)")
                if res.componentsSeparatedByString("Error").count > 1{
                    //println("========postnotification =====\(res)")
                    result = Result(status: "Error",message:res,userinfo:NSObject(),tag:tag)
                    //NSNotificationCenter.defaultCenter().postNotificationName(tag, object: result)
                }else{
                    //println("========postnotification =====\(res)  \(tag)")
                    result = Result(status: "OK",message:res,userinfo:NSObject(),tag:tag)
                    //NSNotificationCenter.defaultCenter().postNotificationName(tag, object: result)
                }
            case Config.RequestTag.PostCustomerLog:
                //println("dispatch \(res)  \(tag)")
                if res.componentsSeparatedByString("Error").count > 1{
                    //println("========postnotification =====\(res)")
                    result = Result(status: "Error",message:res,userinfo:NSObject(),tag:tag)
                    //NSNotificationCenter.defaultCenter().postNotificationName(tag, object: result)
                }else{
                    //println("========postnotification =====\(res)  \(tag)")
                    result = Result(status: "OK",message:res,userinfo:NSObject(),tag:tag)
                    //NSNotificationCenter.defaultCenter().postNotificationName(tag, object: result)
                }
            case Config.RequestTag.GetCustomerAddressBook:
                //只能处理 xml encoding utf-8的
                ////print("取得所内通讯录在线数据 网络解析 开始 ")
                let xml = SWXMLHash.parse(res.stringByReplacingOccurrencesOfString("gb2312", withString: "utf-8"))
                
                let userInfo = NSMutableArray()
                for elem in xml["entries"]["entry"]{
                    
                    let item:CustomerAddressItem = CustomerAddressItem()
                    
                    item.name = elem["name"][0].element?.text ?? ""
                    item.comp = elem["comp"][0].element?.text ?? ""
                    item.group = elem["group"][0].element?.text ?? ""
                    item.comptel = elem["comptel"][0].element?.text ?? ""
                    item.linetel = elem["linetel"][0].element?.text ?? ""
                    item.mobile = elem["mobile"][0].element?.text ?? ""
                    item.email = elem["email"][0].element?.text ?? ""
                    item.important = elem["important"][0].element?.text ?? ""
                    item.importantid = elem["importantid"][0].element?.text ?? ""
                    item.level = elem["level"][0].element?.text ?? ""
                    item.managerlist = elem["managerlist"][0].element?.text ?? ""
                    item.sex = elem["sex"][0].element?.text ?? ""
                    item.jobtitle = elem["jobtitle"][0].element?.text ?? ""
                    item.custlevel = elem["custlevel"][0].element?.text ?? ""
                    item.status = elem["status"][0].element?.text ?? ""
                    item.customerid = elem["customerid"][0].element?.text ?? ""
                    
                    item.query = ""
                    if item.name.isEmpty == false {
                        item.query = item.query + item.name
                    }
                    if item.group.isEmpty == false {
                        item.query = item.query + item.group
                    }
                    if item.mobile.isEmpty == false {
                        item.query = item.query + item.mobile
                    }
                    if item.comp.isEmpty == false {
                        item.query = item.query + item.comp
                    }
                    
                    
                    userInfo.addObject(item)
                }
                result = Result(status: "OK",message:"",userinfo:userInfo,tag:tag)
                //NSNotificationCenter.defaultCenter().postNotificationName(tag, object: result)
                
            case Config.RequestTag.GetCustomerAddressBook_Group:
                
                //只能处理 xml encoding utf-8的
                let xml = SWXMLHash.parse(res.stringByReplacingOccurrencesOfString("gb2312", withString: "utf-8"))
                let userInfo = NSMutableArray()
                for elem in xml["entries"]["entry"]{
                    let item:CustomerAddressGroupItem = CustomerAddressGroupItem()
                    item.name = elem["group"][0].element?.text ?? ""
                    item.level = elem["custlevel"][0].element?.text ?? ""
                    if item.name != "" {
                        userInfo.addObject(item)
                    }
                    
                }
                result = Result(status: "OK",message:"",userinfo:userInfo,tag:tag)
            //NSNotificationCenter.defaultCenter().postNotificationName(tag, object: result)
            case Config.RequestTag.GetParameter_CallDuration:
                var userInfo = ""
                //只能处理 xml encoding utf-8的
                let json = JSONClass(string:res)
                userInfo = json["JSON"][0]["value"].asString  ?? "++"
                result = Result(status: "OK",message:"",userinfo:userInfo,tag:tag)
                //NSNotificationCenter.defaultCenter().postNotificationName(tag, object: result)
                
                
            default:
                return        
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                
                //这里返回主线程，写需要主线程执行的代码
                //println("这里返回主线程，写需要主线程执行的代码  --  Dispatch")
                NSNotificationCenter.defaultCenter().postNotificationName(tag, object: result)
            })
        }) 
        
        
        
    }
    
    /*
     //获取图片资源，启用缓存功能 并保存本地CacheStorage
     -(void) addRequestWithUrlString:(NSString *)urlString Method:(NSString *)requestMethod Tag:(RequestTag) tag Index:(NSInteger)index{
     //根据基础地址跟API合成链接，创建请求
     if (!urlString) {
     return;
     }
     
     NSString *fullUrlString = [NSString stringWithFormat:@"%@%@",URL_BASE,urlString];
     NSURL *url=[NSURL URLWithString:fullUrlString];
     
     NSNumber *indexNum=[NSNumber numberWithInteger:index];
     NSDictionary *userInfoDic=[NSDictionary dictionaryWithObject:indexNum forKey:@"index"];
     
     ASIHTTPRequest *request=[[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
     //    [request setAllowCompressedResponse:NO];
     //    [request setShouldWaitToInflateCompressedResponses:NO];
     
     [request setRequestMethod:requestMethod];
     [request setTag:tag];
     [request setUserInfo:userInfoDic];
     
     [request setDownloadCache:[ASIDownloadCache sharedCache]];
     [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
     //缓存
     
     [self.networkQueue addOperation:request];
     }
     */
    
    func URLSession(session: NSURLSession,didReceiveChallenge challenge:NSURLAuthenticationChallenge,
                    completionHandler:(NSURLSessionAuthChallengeDisposition,NSURLCredential?) -> Void) {
        //let username = NSUserDefaults.standardUserDefaults().valueForKey("UserName") as String
        //let password = NSUserDefaults.standardUserDefaults().valueForKey("Password") as String
        //print("host 55555 = \(challenge.protectionSpace.host)")
        let username = Message.shared.postUserName
        let password = Message.shared.postPassword
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust  {
            print("send credential Server Trust \(String(success_auth))")
            let credential:NSURLCredential = NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!)
            completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential,credential)
        }else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic{
            print("send credential HTTP Basic \(String(success_auth))")
            let defaultCredentials: NSURLCredential = NSURLCredential(user: Config.Net.Domain+"\\"+username, password: password, persistence:NSURLCredentialPersistence.ForSession)
            completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential,defaultCredentials)
            
        }else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodNTLM{
            print("challenge host= \(self.serverlist[challenge.protectionSpace.host])")
            //if self.alive == false {
            if self.serverlist[challenge.protectionSpace.host] != true {
                //if success_auth == 0 {
                //print("send credential NTLM with user credential \(String(success_auth))")
                let defaultCredentials: NSURLCredential = NSURLCredential(user: Config.Net.Domain+"\\"+username, password: password, persistence:NSURLCredentialPersistence.ForSession)
                completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential,defaultCredentials)
                success_auth = success_auth + 1  
                //} else
                //{
                //    println("Cancel Challenge \(String(success_auth))")
                //    completionHandler(NSURLSessionAuthChallengeDisposition.CancelAuthenticationChallenge,nil)
                //}
            }else{
                print("Challenge Credential Default alive \(String(success_auth))")
                completionHandler(NSURLSessionAuthChallengeDisposition.PerformDefaultHandling,nil)
            }
            
            
        } else{
            challenge.sender!.performDefaultHandlingForAuthenticationChallenge!(challenge)
        }
    }
    
    func URLSession(session: NSURLSession,task: NSURLSessionTask,willPerformHTTPRedirection response:NSHTTPURLResponse,newRequest request: NSURLRequest,
                    completionHandler: (NSURLRequest!) -> Void) {
        let newRequest : NSURLRequest? = request
        //print("willPerformHTTPRedirection");
        completionHandler(newRequest)
    }
    
    
}