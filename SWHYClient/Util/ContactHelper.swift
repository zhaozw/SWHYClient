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
    
    func getMyContacts() -> [Person] {
        var error:Unmanaged<CFErrorRef>?
        var addressBook: ABAddressBookRef = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
        
        let authStatus = ABAddressBookGetAuthorizationStatus()
        
        if authStatus == ABAuthorizationStatus.Denied || authStatus == ABAuthorizationStatus.NotDetermined {
            // Ask for permission
            var sema = dispatch_semaphore_create(0)
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
            var fname = ABRecordCopyValue(record, kABPersonFirstNameProperty)?.takeRetainedValue() as? NSString
            var lname = ABRecordCopyValue(record, kABPersonLastNameProperty)?.takeRetainedValue() as? NSString
            
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
        retContacts.sort { (p1:Person, p2:Person) in
            if p1.name < p2.name {
                return true
            }
            return p1.email < p2.email
        }
        
        return retContacts
    }
    
    // Internal helper method.
    func getMultiProperty(record:ABRecordRef, _ property:ABPropertyID, _ suffix:String) -> [String:String]? {
        var values:ABMultiValueRef? = ABRecordCopyValue(record, property)?.takeRetainedValue()
        if values != nil {
            var propertyDict:Dictionary = [String:String]()
            for i in 0 ..< ABMultiValueGetCount(values) {
                // Convert to String as the returning value is a NSSting type
                var label = ABMultiValueCopyLabelAtIndex(values, i)?.takeRetainedValue() as? String
                // Convert to NSString (which is an object) as the returning value is AnyObject
                var value = ABMultiValueCopyValueAtIndex(values, i)?.takeRetainedValue() as? NSString
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
        var addressBook: ABAddressBookRef = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
        let record: ABRecord! = ABAddressBookGetPersonWithRecordID(addressBook, recordID)?.takeRetainedValue()
        ABPersonGetCompositeNameFormatForRecord(record)
        // TBD
        return ""
    }
    
    // Show the formatted information string for a specific person
    // e.g. [name] hasFaceTime: Y/N hasPicture: Y/N
    func getDetailedInfo(recordID: ABRecordID) -> String {
        var error:Unmanaged<CFErrorRef>?
        var addressBook: ABAddressBookRef = ABAddressBookCreateWithOptions(nil, &error).takeUnretainedValue()
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
        var addressBook: ABAddressBook = ABAddressBookCreateWithOptions(nil, &error).takeUnretainedValue()
        let record: ABRecord! = ABAddressBookGetPersonWithRecordID(addressBook, recordID)?.takeUnretainedValue()
        var result = ABAddressBookRemoveRecord(addressBook, record, &error)
        if error != nil {
            println("Failed to delete address book entry: \(recordID)")
            return false
        }
        // Don't forget to save the address book to persistent the state.
        result = ABAddressBookSave(addressBook, &error)
        if error != nil {
            println("Failed to save address book: \(recordID)")
            return false
        }
        return result
    }
    
    //-------
    
    func removeAllFromAddressBookByGroupName(groupName:String){
        let stat = ABAddressBookGetAuthorizationStatus()
        var message:String = ""
        switch stat {
        case .Denied, .Restricted:
            println("no access to addressbook")
            message = "没有权限访问手机通讯录"
        case .Authorized, .NotDetermined:
            var err : Unmanaged<CFError>? = nil
            var adbk : ABAddressBook? = ABAddressBookCreateWithOptions(nil, &err).takeRetainedValue()
            if adbk == nil {
                println(err)
                message = "无法访问手机通讯录"    
            }
            ABAddressBookRequestAccessWithCompletion(adbk) {
                (granted:Bool, err:CFError!) in
                if granted {
                    var success:Bool = false
                    //创建或者取得地址本内置分组
                    let groupid:ABRecordID? = self.getOrCreateGroup(Config.AddressBook.SyncAddressBookGroupName)
                    if groupid != nil {
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
                                   
                                    println("Failed to delete address book entry: \(person)")
                                }
                                
                                
                            }
                            // Don't forget to save the address book to persistent the state.
                            success = ABAddressBookSave(adbk, &error)
                            if error != nil {
                                message = "删除所内通讯录拷贝失败"
                                println("Failed to save address book")
                            }
                        }
                    }
                } else {
                    println(err)
                    message = "无法访问手机通讯录"
                }
            }
        }     
        message = "删除所内通讯录拷贝成功"
        var result:Result = Result(status: "Done",message:message,userinfo:NSObject(),tag:Config.NotifyTag.RevokeRemoveAddressbook)
        NSNotificationCenter.defaultCenter().postNotificationName(Config.NotifyTag.RevokeRemoveAddressbook, object: result)        
    }
    
    
    // Adds a contact to the AddressBook
    func syncToAddressBook(itemlist: [InnerAddressItem]){
        func createMultiStringRef() -> ABMutableMultiValueRef {
            let propertyType: NSNumber = kABMultiStringPropertyType
            return Unmanaged.fromOpaque(ABMultiValueCreateMutable(propertyType.unsignedIntValue).toOpaque()).takeUnretainedValue() as NSObject as ABMultiValueRef
        }
        
        let stat = ABAddressBookGetAuthorizationStatus()
        var message:String = ""
        switch stat {
        case .Denied, .Restricted:
            println("no access to addressbook")
            message = "没有权限访问手机通讯录"
        case .Authorized, .NotDetermined:
            var err : Unmanaged<CFError>? = nil
            var adbk : ABAddressBook? = ABAddressBookCreateWithOptions(nil, &err).takeRetainedValue()
            if adbk == nil {
                println(err)
                message = "无法访问手机通讯录"
                return
            }
            ABAddressBookRequestAccessWithCompletion(adbk) {
                (granted:Bool, err:CFError!) in
                if granted {
                    //创建或者取得地址本内置分组
                    let groupid:ABRecordID? = self.getOrCreateGroup(Config.AddressBook.SyncAddressBookGroupName)
                    if groupid != nil {
                        let group:ABRecordRef = ABAddressBookGetGroupWithRecordID(adbk,groupid!).takeUnretainedValue()
                        
                        println("groupid \(groupid) ")
                        
                        //var newContact:ABRecordRef! = ABPersonCreate().takeRetainedValue()
                        var newContact:ABRecordRef
                        var phoneNumbers: ABMutableMultiValueRef
                        
                        var success:Bool = false
                        
                        //Updated to work in Xcode 6.1
                        var error: Unmanaged<CFErrorRef>? = nil
                        //Updated to error to &error so the code builds in Xcode 6.1
                        for item in itemlist{
                            println(item.name)
                            newContact = ABPersonCreate().takeRetainedValue()
                            
                            success = ABRecordSetValue(newContact, kABPersonFirstNameProperty, item.name, &error)
                            success = ABRecordSetValue(newContact, kABPersonDepartmentProperty, item.dept, &error)
                            
                                                       
                            var phoneNumbers: ABMutableMultiValueRef =  createMultiStringRef()
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
                            //println("Saving addressbook successful? \(success) \(error)")
                            
                            success = ABGroupAddMember(group, newContact, &error)
                            //success = ABAddressBookSave(adbk, &error)
                            
                            //println("Saving addressbook successful? \(success) \(group.name) \(error)")
                        }
                        success = ABAddressBookSave(adbk, &error)
                        if success == true{
                            message = "所内通讯录拷贝至手机通讯录成功"
                        }else{
                            message = "所内通讯录拷贝至手机通讯录失败"
                        }
                    }
                    
                    
                    
                    
                    //}
                } else {
                    println(err)
                    message = "没有权限访问手机通讯录"
                }
                var result:Result = Result(status: "Done",message:message,userinfo:NSObject(),tag:Config.NotifyTag.RevokeSyncAddressbook)
                NSNotificationCenter.defaultCenter().postNotificationName(Config.NotifyTag.RevokeSyncAddressbook, object: result)
                
            }
        }     
    }   
    
    func getOrCreateGroup(groupName:String) -> ABRecordID? {
        var success:Bool = false
        
        var err : Unmanaged<CFError>? = nil
        var adbk : ABAddressBook? = ABAddressBookCreateWithOptions(nil, &err).takeRetainedValue()
        if adbk == nil {
            println(err)
            return nil
        }
        
        var groupCount:CFIndex = ABAddressBookGetGroupCount(adbk)
        var groupLists:NSArray = ABAddressBookCopyArrayOfAllGroups(adbk).takeRetainedValue() as NSArray
        var currentCheckedGroup:ABRecordRef
        var currentGroupName:String = ""
        
        
        for group in groupLists {
            currentGroupName = ABRecordCopyValue(group, kABGroupNameProperty)?.takeRetainedValue() as! String
            if (currentGroupName == groupName){
                println("====get exixt groupname \(groupName)")
                return ABRecordGetRecordID(group)
                //return group
            }
        }
        
        var newGroup:ABRecordRef! = ABGroupCreate().takeRetainedValue()
        success = ABRecordSetValue(newGroup, kABGroupNameProperty, groupName, &err)
        success = ABAddressBookAddRecord(adbk, newGroup, &err)
        success = ABAddressBookSave(adbk, &err)
        println("----------create a new groupname \(groupName)")
        return ABRecordGetRecordID(newGroup)
        //return newGroup
    }
    
   
    //--------
    
    //========
}