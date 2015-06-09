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