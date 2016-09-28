//
//  ContactsHelper.swift
//  MyContacts
//
//  Created by Wei  Wang on 14/12/20.
//  Copyright (c) 2014年 Wei  Wang. All rights reserved.
//

import Foundation
import AddressBook
import AddressBookUI

class ContactsHelper {
    
    struct Person {
        var id: ABRecordID = (-1)
        var name: String = ""
        var phone: String = ""
        var email: String = ""
        var firstName:String = ""
        var lastName:String = ""
        var phoneNumber:String = ""
        var jobTitle:String = ""
        //var checked: Bool = false
    }
    
    init() {
        
    }
    /*
     func getMyContacts() -> [Person] {
     var error:Unmanaged<CFErrorRef>?
     let addressBook: ABAddressBookRef = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
     
     let authStatus = ABAddressBookGetAuthorizationStatus()
     
     if authStatus == ABAuthorizationStatus.Denied || authStatus == ABAuthorizationStatus.NotDetermined {
     // Ask for permission
     let sema = dispatch_semaphore_create(0)
     ABAddressBookRequestAccessWithCompletion(addressBook, { (success, error) in
     if success {
     ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray
     dispatch_semaphore_signal(sema)
     }
     })
     dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER)
     
     }
     return extractMyContracts(ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray)
     }
     
     func extractMyContracts(contacts: NSArray) -> [Person] {
     
     //var retContacts:Array = [[String:String]]()
     var retContacts = [Person]()
     
     for record in contacts {
     var person = Person()
     let fname = ABRecordCopyValue(record, kABPersonFirstNameProperty)?.takeRetainedValue() as? NSString
     let lname = ABRecordCopyValue(record, kABPersonLastNameProperty)?.takeRetainedValue() as? NSString
     
     // TODO: Compose the full name according to locale: call getCompositeName()
     person.name = (lname == nil ? "" : lname as! String) + (fname == nil ? "" : fname as! String)
     // Get one of the phone attributes
     for (key, value) in getMultiProperty(record, kABPersonPhoneProperty, "Phone") ?? ["":""] {
     if (value != "") {
     person.phone = value
     break
     }
     }
     // Get one of the email attributes
     for (_, value) in getMultiProperty(record, kABPersonEmailProperty, "Email") ?? ["":""] {
     if (value != "") {
     person.email = value
     break
     }
     }
     // Refine it before returning (for debugging purpose)
     if person.name.isEmpty {
     //person.name = "-"
     }
     if person.phone.isEmpty {
     person.phone = "~"
     }
     person.id = ABRecordGetRecordID(record)
     retContacts.append(person)
     }
     
     // Sort it
     retContacts.sortInPlace { (p1:Person, p2:Person) in
     if p1.name < p2.name {
     return true
     }
     return p1.email < p2.email
     }
     
     return retContacts
     }
     
     // Internal helper method.
     func getMultiProperty(record:ABRecordRef, _ property:ABPropertyID, _ suffix:String) -> [String:String]? {
     let values:ABMultiValueRef? = ABRecordCopyValue(record, property)?.takeRetainedValue()
     if values != nil {
     var propertyDict:Dictionary = [String:String]()
     for i in 0 ..< ABMultiValueGetCount(values) {
     // Convert to String as the returning value is a NSSting type
     let label = ABMultiValueCopyLabelAtIndex(values, i)?.takeRetainedValue() as? String
     // Convert to NSString (which is an object) as the returning value is AnyObject
     let value = ABMultiValueCopyValueAtIndex(values, i)?.takeRetainedValue() as? NSString
     switch property {
     case kABPersonAddressProperty:
     var TODO = 1
     case kABPersonSocialProfileProperty:
     var TODO = 2
     default:
     var debug = 3
     //propertyDict[label] = value.takeRetainedValue() as? String ?? ""
     propertyDict["\(label)\(suffix)"] = value as? String
     }
     }
     return propertyDict
     } else {
     return nil
     }
     }
     
     func getCompositeName(recordID: ABRecordID) -> String {
     var error:Unmanaged<CFErrorRef>?
     let addressBook: ABAddressBookRef = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
     let record: ABRecord! = ABAddressBookGetPersonWithRecordID(addressBook, recordID)?.takeRetainedValue()
     ABPersonGetCompositeNameFormatForRecord(record)
     // TBD
     return ""
     }
     
     // Show the formatted information string for a specific person
     // e.g. [name] hasFaceTime: Y/N hasPicture: Y/N
     func getDetailedInfo(recordID: ABRecordID) -> String {
     var error:Unmanaged<CFErrorRef>?
     let addressBook: ABAddressBookRef = ABAddressBookCreateWithOptions(nil, &error).takeUnretainedValue()
     let record: ABRecord! = ABAddressBookGetPersonWithRecordID(addressBook, recordID)?.takeUnretainedValue()
     let hasPicture: String = ABPersonHasImageData(record) ? "Y" : "N"
     var hasURL: String = "N"
     // Get the URL attributes
     for (_, value) in getMultiProperty(record, kABPersonURLProperty, "URL") ?? ["":""] {
     if (value != "") {
     hasURL = "Y"
     break
     }
     }
     return "hasHomepage:\(hasURL) hasPicture:\(hasPicture)"
     }
     
     // Delete an entry/record
     func deleteAddressBookEntry(recordID: ABRecordID) -> Bool {
     var error:Unmanaged<CFErrorRef>?
     let addressBook: ABAddressBook = ABAddressBookCreateWithOptions(nil, &error).takeUnretainedValue()
     let record: ABRecord! = ABAddressBookGetPersonWithRecordID(addressBook, recordID)?.takeUnretainedValue()
     var result = ABAddressBookRemoveRecord(addressBook, record, &error)
     if error != nil {
     // print("Failed to delete address book entry: \(recordID)")
     return false
     }
     // Don't forget to save the address book to persistent the state.
     result = ABAddressBookSave(addressBook, &error)
     if error != nil {
     //print("Failed to save address book: \(recordID)")
     return false
     }
     return result
     }
     */
    //-------
    
    func removeAllFromAddressBookByGroupName(groupName:String,tag:String){
        let stat = ABAddressBookGetAuthorizationStatus()
        var message:String = ""
        var status:String = ""
        switch stat {
        case .Denied, .Restricted:
            //print("no access to addressbook")
            message = "没有权限访问手机通讯录"
            status = "Error"
            let result:Result = Result(status: status,message:message,userinfo:NSObject(),tag:tag)
            NSNotificationCenter.defaultCenter().postNotificationName(tag, object: result)
        case .Authorized, .NotDetermined:
            var err : Unmanaged<CFError>? = nil
            //print("do not detemined")
            let adbk : ABAddressBook? = ABAddressBookCreateWithOptions(nil, &err).takeRetainedValue()
            if adbk == nil {
                print(err)
                message = "无法访问手机通讯录"
                status = "Error"
                print(message)
                
                let result:Result = Result(status: status,message:message,userinfo:NSObject(),tag:tag)
                NSNotificationCenter.defaultCenter().postNotificationName(tag, object: result)
            }else{
                ABAddressBookRequestAccessWithCompletion(adbk) {
                    (granted:Bool, err:CFError!) in
                    if granted {
                        do {
                            message = "granted"
                            var success:Bool = false
                            //创建或者取得地址本内置分组
                            let groupid:ABRecordID? = self.getOrCreateGroup(Config.AddressBook.SyncAddressBookGroupName)
                            print("get groupid \(groupid)")
                            if groupid != nil {
                                if groupid != -1{
                                    let group:ABRecordRef = ABAddressBookGetGroupWithRecordID(adbk,groupid!).takeUnretainedValue()
                                    //ABGroup
                                    let tmparray = ABGroupCopyArrayOfAllMembers(group)
                                    if tmparray != nil{
                                        let personlist:NSArray? = tmparray.takeRetainedValue() as NSArray
                                        
                                        //let personlist:NSArray? = ABGroupCopyArrayOfAllMembers(group).takeRetainedValue() as NSArray
                                        var error: Unmanaged<CFErrorRef>? = nil
                                        
                                        for person in personlist!{
                                            var result = ABAddressBookRemoveRecord(adbk, person, &error)
                                            if error != nil {
                                                status = "Error"
                                                print("Failed to delete address book entry: \(person)")
                                            }
                                            
                                            
                                        }
                                        // Don't forget to save the address book to persistent the state.
                                        success = ABAddressBookSave(adbk, &error)
                                        if error != nil {
                                            message = "删除所内通讯录拷贝失败"
                                            status = "Error"
                                            print("Failed to save address book")
                                        }else{
                                            status = "OK"
                                            message = "删除所内通讯录拷贝成功"
                                        }
                                    }else{
                                        status = "OK"
                                        message = "本地没有所内通讯录拷贝成员"
                                    }
                                }else{
                                    status = "Error"
                                    message = "操作失败 请检查 设置 通讯录 默认账号 为iCloud"
                                }       
                            }else{
                                status = "OK"
                                message = "本地没有所内通讯录拷贝"
                            }
                        } catch {
                            status = "Error"
                            message = "操作失败，请检查 设置 - 邮件、通讯录、日历的通讯录默认账户 为 iCloud"
                            
                        }
                    } else {
                        print(err)
                        status = "Error"
                        message = "无法访问手机通讯录"
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        //这里返回主线程，写需要主线程执行的代码
                        print("main queue remove \(message)")
                        let result:Result = Result(status: status,message:message,userinfo:NSObject(),tag:tag)
                        NSNotificationCenter.defaultCenter().postNotificationName(tag, object: result)
                        
                    })
                }
            }
        }
        
    }
    
    
    // Adds a contact to the AddressBook
    func syncToAddressBook(itemlist: [InnerAddressItem],tag:String){
        func createMultiStringRef() -> ABMutableMultiValueRef {
            let propertyType: NSNumber = kABMultiStringPropertyType
            return Unmanaged.fromOpaque(ABMultiValueCreateMutable(propertyType.unsignedIntValue).toOpaque()).takeUnretainedValue() as NSObject as ABMultiValueRef
        }
        
        let stat = ABAddressBookGetAuthorizationStatus()
        var message:String = ""
        var status:String = ""
        switch stat {
        case .Denied, .Restricted:
            print("sync no access to addressbook")
            message = "没有权限访问手机通讯录"
            status = "Error"
            let result:Result = Result(status: status,message:message,userinfo:NSObject(),tag:tag)
            NSNotificationCenter.defaultCenter().postNotificationName(tag, object: result)
            
        case .Authorized, .NotDetermined:
            print("sync access to addressbook")
            var err : Unmanaged<CFError>? = nil
            let adbk : ABAddressBook? = ABAddressBookCreateWithOptions(nil, &err).takeRetainedValue()
            if adbk == nil {
                print(err)
                message = "无法访问手机通讯录"
                status = "Error"
                print(message)
                
                let result:Result = Result(status: status,message:message,userinfo:NSObject(),tag:tag)
                NSNotificationCenter.defaultCenter().postNotificationName(tag, object: result)
            }else{
                ABAddressBookRequestAccessWithCompletion(adbk) {
                    (granted:Bool, err:CFError!) in
                    if granted {
                        do {
                            //创建或者取得地址本内置分组
                            let groupid:ABRecordID? = self.getOrCreateGroup(Config.AddressBook.SyncAddressBookGroupName)
                            if groupid != nil {
                                let group:ABRecordRef = ABAddressBookGetGroupWithRecordID(adbk,groupid!).takeUnretainedValue()
                                
                                print("groupid \(groupid) ")
                                
                                //var newContact:ABRecordRef! = ABPersonCreate().takeRetainedValue()
                                var newContact:ABRecordRef
                                var phoneNumbers: ABMutableMultiValueRef
                                
                                var success:Bool = false
                                
                                //Updated to work in Xcode 6.1
                                var error: Unmanaged<CFErrorRef>? = nil
                                //Updated to error to &error so the code builds in Xcode 6.1
                                print("sync itemlist =\(itemlist.count)")
                                for item in itemlist{
                                    //print(item.name)
                                    newContact = ABPersonCreate().takeRetainedValue()
                                    
                                    success = ABRecordSetValue(newContact, kABPersonFirstNameProperty, item.name, &error)
                                    success = ABRecordSetValue(newContact, kABPersonDepartmentProperty, item.dept, &error)
                                    
                                    
                                    let phoneNumbers: ABMutableMultiValueRef =  createMultiStringRef()
                                    ABMultiValueAddValueAndLabel(phoneNumbers, item.linetel, "直线", nil)
                                    ABMultiValueAddValueAndLabel(phoneNumbers, item.mobile, "移动手机", nil)
                                    ABMultiValueAddValueAndLabel(phoneNumbers, item.mobile1, "移动短号", nil)
                                    ABMultiValueAddValueAndLabel(phoneNumbers, item.mobiletelecom, "电信手机", nil)
                                    ABMultiValueAddValueAndLabel(phoneNumbers, item.mobiletelecom1, "电信短号", nil)
                                    ABMultiValueAddValueAndLabel(phoneNumbers, item.homephone, "家庭电话", nil)
                                    ABMultiValueAddValueAndLabel(phoneNumbers, item.othertel, "其他电话", nil)
                                    success = ABRecordSetValue(newContact, kABPersonPhoneProperty, phoneNumbers, &error)
                                    
                                    
                                    success = ABRecordSetValue(newContact, kABPersonNoteProperty, item.researchteam, &error)
                                    
                                    success = ABAddressBookAddRecord(adbk, newContact, &error)
                                    //success = ABAddressBookSave(adbk, &error)
                                    //print("Saving addressbook successful? \(success) \(error)")
                                    
                                    success = ABGroupAddMember(group, newContact, &error)
                                    //如何保存至group失败 则退出 并且不保存此次同步结果
                                    if success == false{
                                        status = "Error"
                                        message = "操作失败 请检查 设置 通讯录 默认账号 为iCloud"
                                        break
                                    }
                                    //success = ABAddressBookSave(adbk, &error)
                                    
                                    //print("add group addressbook successful? \(success) \(group) \(error)")
                                }
                                if status != "Error" {
                                    success = ABAddressBookSave(adbk, &error)
                                    if success == true{
                                        status = "Done"
                                        message = "所内通讯录拷贝至手机通讯录成功"
                                    }else{
                                        status = "Error"
                                        message = "所内通讯录拷贝至手机通讯录失败"
                                    }
                                }
                            }
                        } catch {
                            status = "Error"
                            message = "操作失败，请检查 设置 - 邮件、通讯录、日历的通讯录默认账户 为 iCloud"
                            
                        }
                    } else {
                        print(err)
                        message = "没有权限访问手机通讯录"
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        //这里返回主线程，写需要主线程执行的代码
                        print("sync \(message)")
                        let result:Result = Result(status: status,message:message,userinfo:NSObject(),tag:tag)
                        NSNotificationCenter.defaultCenter().postNotificationName(tag, object: result)
                        
                    })
                }
            }
        }     
        
    }   
    
    func getOrCreateGroup(groupName:String) -> ABRecordID? {
        var success:Bool = false
        
        var err : Unmanaged<CFError>? = nil
        let adbk : ABAddressBook? = ABAddressBookCreateWithOptions(nil, &err).takeRetainedValue()
        if adbk == nil {
            print(err)
            return nil
        }
        
        var groupCount:CFIndex = ABAddressBookGetGroupCount(adbk)
        let groupLists:NSArray = ABAddressBookCopyArrayOfAllGroups(adbk).takeRetainedValue() as NSArray
        var currentCheckedGroup:ABRecordRef
        var currentGroupName:String = ""
        
        
        for group in groupLists {
            currentGroupName = ABRecordCopyValue(group, kABGroupNameProperty)?.takeRetainedValue() as! String
            if (currentGroupName == groupName){
                print("====get exixt groupname \(groupName)")
                return ABRecordGetRecordID(group)
                //return group
            }
        }
        
        let newGroup:ABRecordRef! = ABGroupCreate().takeRetainedValue()
        success = ABRecordSetValue(newGroup, kABGroupNameProperty, groupName, &err)
        success = ABAddressBookAddRecord(adbk, newGroup, &err)
        success = ABAddressBookSave(adbk, &err)
        print("----------create a new groupname \(groupName)")
        return ABRecordGetRecordID(newGroup)
        //return newGroup
    }
    
    
    //--------
    
    //========
}