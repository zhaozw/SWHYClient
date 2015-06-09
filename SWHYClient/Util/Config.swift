//
//  Config.swift
//  SWHY_Moblie
//
//  Created by sunny on 3/19/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//

import Foundation
class Config{

    struct RequestTag { 
        static let DoLogin = "DoLogin"
        static let GetMainMenu = "GetMainMenu"
        static let GetInnerAddressBook = "GetInnerAddressBook"
        static let GetInnerAddressBook_Dept = "GetInnerAddressBook_Dept"
        
        static let GetCustomerAddressBook = "GetCustomerAddressBook"
        static let GetCustomerAddressBook_Group = "GetCustomerAddressBook_Group"
        
        static let WebViewPreGet = "WebViewPreGet"
        
        static let PostAccessLog = "PostAccessLog"
        static let PostCustomerLog = "PostCustomerLog"
    } 

    struct NotifyTag {
        static let RevokeSyncAddressbook = "RevokeSyncAddressbook"
        static let RevokeRemoveAddressbook = "RevokeRemoveAddressbook"
    }
    
    struct Encoding {
        static let GB2312 = CFStringEncodings.GB_18030_2000.rawValue
    }
    
    struct URL {
        static let BaseURL = "https://swinbak.swsresearch.net"
        static let Login = "https://swinbak.swsresearch.net/Mobile/mobileInterface.nsf/ag_checkMobile?Openagent"
        static let ToDoList = "https://swinbak.swsresearch.net/Mobile/MobileFlow.nsf/fm_workflowplatform?openform"
        static let MainMenuList = "https://swinbak.swsresearch.net/Mobile/mobileInterface.nsf/fm_showMobileHP_ios?readForm"
        static let InnerAddressBook = "https://swinbak.swsresearch.net/Portal/SysBase/SysUserInfo.nsf/fm_allPersonXML?readform"
        static let InnerAddressBook_Dept = "https://swinbak.swsresearch.net/portal/SysBase/SysAppReg.nsf/fm_allDeptXML?readform"
        
        static let CustomerAddressBook = "https://swinbak.swsresearch.net/mobile/customerinfo.nsf/GetCustomerInfoByUserName?openagent"
        static let CustomerAddressBook_Group = "https://swinbak.swsresearch.net/mobile/customerinfo.nsf/GetGroupInfoByUserName?openagent"
        
        static let PostAccessLog = "https://swinbak.swsresearch.net/mobile/Log.nsf/DoPostAccessLog?openagent"
        static let PostCustomerLog = "https://swinbak.swsresearch.net/mobile/Log.nsf/DoPostCustomerLog?openagent"
    }
    struct Net {
        static let Domain = "swsresearch"
        static let ClientType = "ios"
    }
    
    struct UI {
        static let Title = "申万宏源证券研究所"
        static let PreNavItem = "< 返回"
        
    }
    
    struct TableName {
        static let MainMenuList = "MainMenuList"
        static let InnerAddressList = "InnerAddressList"
        static let InnerAddressDeptList = "InnerAddressDeptList"
        
        static let CustomerAddressList = "CustomerAddressList"
        static let CustomerAddressGroupList = "CustomerAddressGroupList"
        
        static let AccessLogList = "AccessLogList"
        static let CustomerLogList = "CustomerLogList"
    }
    
    struct AddressBook {
        static let SyncAddressBookGroupName = "所内通讯录"
    }

}