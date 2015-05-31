//
//  Loger.swift
//  SWHYClient
//
//  Created by sunny on 5/6/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//-------

import Foundation
class Loger:NSObject{
    
    class var shared: Loger {
        return Inner.instance
    }
    
    struct Inner {
        static let instance = Loger()
    }
    
    
    func updateAccessLogList() -> String{
        
        //作废函数
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
            
            NetworkEngine.sharedInstance.postLogList(Config.URL.PostAccessLog, tag: Config.RequestTag.PostAccessLog)
            
        }else{
            
            return "Success: No Record to Upload"
            
        }
        return ""
        
    }
    
    
    
    
}