//
//  CustomerAddressItem.swift
//  SWHYClient
//
//  Created by sunny on 5/27/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//

import Foundation
class CustomerAddressItem {
    
        
    var name:String!; // 姓名
    var comp:String! ; // 公司简称
    var group:String! ; // 人脉群组
    var comptel:String! ; // 总机-分机
    var linetel:String! ; // 直线
    var mobile:String! ; // 手机
    var email:String! ; // 电子邮件
    var important:String! ; // 重要程度 (潜在成长 ,一般关注)
    var importantid:String! ; // 重要程度ID
    var level:String! ; // 客户级别
    var managerlist:String! ; // 客户经理
    var sex:String! ;            //性别
    var jobtitle:String! ;      //职务
    var custlevel:String! ;     //人脉级别  重点人脉  次要人脉
    var pic:String! ;                  //图片
    var status:String! ;        //状态,现在,潜在
    var customerid:String! ;    //CRM中的客户ID
    var query:String!
    

    
    
    init(){}
}