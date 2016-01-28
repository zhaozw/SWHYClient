//
//  Message.swift
//  SWHYClient
//
//  Created by sunny on 4/9/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//


//用单例方法进行传值
import Foundation
class Message {
    var curMenuItem:MainMenuItemBO = MainMenuItemBO()   //从MainMenuList转至其它界面时传过去的MenuItem对象
    var curInnerAddressItem:InnerAddressItem = InnerAddressItem()
    var curCustomerAddressItem:CustomerAddressItem = CustomerAddressItem()
    var loginType:String = ""
    var postUserName:String = ""                //每次点击登陆按钮时 需要传到登陆验证NetworkEngine中的用户名和密码
    var postPassword:String  = ""               //每次点击登陆按钮时 需要传到登陆验证NetworkEngine中的用户名和密码
    var logout:Bool = false                     //是否登出状态
    var version:String = ""
    var upgradeURL:String = ""
    class var shared: Message {
        return Inner.instance
    }
    
    struct Inner {
        static let instance = Message()
    }
}