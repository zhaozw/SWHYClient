//
//  CustomerLogItem.swift
//  SWHYClient
//
//  Created by sunny on 6/9/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//

import Foundation
class CustomerLogItem {
       
    var id:Int!     //数据库表记录号
    var user:String!        // 人员账号
    var module:String!      // 模块简称
    var customerid:String!      // CRM客户ID
    var phonenumber:String!     // 拨打电话号码
    var type:String!            //通话类型  1 接入 2 拨出
    var startdatetime:String!       // 拨打开始时间
    var enddatetime:String!     // 拨打结束时间
    var duration:String!        //通话时间
    
    var sync:String!        //是否同步
    
    init(){}
    
    
}