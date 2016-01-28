//
//  DBAdapter.swift
//  SWHYClient
//
//  Created by sunny on 4/14/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//

import Foundation


class DBAdapter {
    //Execute 返回 0 代表执行不成功
    private let db = SQLiteDB.sharedInstance()
    private let queue1:dispatch_queue_t = dispatch_queue_create("sqlite_db_queue", DISPATCH_QUEUE_SERIAL)
    class var shared: DBAdapter {
        return Inner.instance
    }
    
    struct Inner {
        static let instance = DBAdapter()
    }
    
    
    //处理表数据前，先判断表是否存在，如果不存在，则创建，以备后续使用该表
    func initTable() -> Int {
        //如果没有对应表 就直接创建一个
        print("----Init Table------------")
        //MainMenuList
        let SQL_DB_CREATE_MAINMENULIST = "CREATE TABLE IF NOT EXISTS \(Config.TableName.MainMenuList) ( id text primary key, itemtext text, uri text, class text, offline text,itemimage text,icon BLOB, showindex integer, updatetime text)"
        
        let result_mainmenulist = self.db.execute(SQL_DB_CREATE_MAINMENULIST, parameters: nil)
        
        
        //所内通讯录表
        
        let SQL_DB_CREATE_INNERADDRESSLIST = "CREATE TABLE IF NOT EXISTS \(Config.TableName.InnerAddressList) ( empid text primary key, dept text, name text, mobile text, linetel text, mobiletelecom text, mobiletelecom1 text, mobile1 text, othertel text, homephone text, researchteam text, msn text, pic text, query text,showindex integer, updatetime text)"
        
        let result_inneraddresslist = self.db.execute(SQL_DB_CREATE_INNERADDRESSLIST, parameters: nil)
        //所内通讯录部门表
        
        let SQL_DB_CREATE_INNERADDRESSDEPTLIST = "CREATE TABLE IF NOT EXISTS \(Config.TableName.InnerAddressDeptList) ( name text primary key,  showindex integer, updatetime text)"
        
        let result_inneraddressdeptlist = self.db.execute(SQL_DB_CREATE_INNERADDRESSDEPTLIST, parameters: nil)
        
        //客户通讯录
        let SQL_DB_CREATE_CUSTOMERADDRESSLIST = "CREATE TABLE IF NOT EXISTS \(Config.TableName.CustomerAddressList) ( customerid text, comp text, groupname text, name text, mobile text, linetel text, comptel text, email text, important text, importantid text, level text, managerlist text, sex text, jobtitle text, custlevel text, status text, query text,showindex integer, updatetime text, PRIMARY KEY(customerid, groupname))"
        
        let result_customeraddresslist = self.db.execute(SQL_DB_CREATE_CUSTOMERADDRESSLIST, parameters: nil)
        
        //let SQL_DB_INDEX = "CREATE UNIQUE INDEX IF NOT EXISTS idx_CustomerAddress ON \(Config.TableName.CustomerAddressList)(customerid,custlevel)"
        //let result_customeraddresslist_index = self.db.execute(SQL_DB_INDEX, parameters: nil)
        //println(result_customeraddresslist        )
        //客户通讯录群组表
        
        let SQL_DB_CREATE_CUSTOMERADDRESSGROUPLIST = "CREATE TABLE IF NOT EXISTS \(Config.TableName.CustomerAddressGroupList) ( name text primary key,  level text , showindex integer, updatetime text)"
        
        let result_customeraddresslist_group = self.db.execute(SQL_DB_CREATE_CUSTOMERADDRESSGROUPLIST, parameters: nil)
        
        //访问日志
        let SQL_DB_CREATE_ACCESSLOGLIST = "CREATE TABLE IF NOT EXISTS \(Config.TableName.AccessLogList) ( id INTEGER primary key AUTOINCREMENT, userid text, type text, online text, moduleid text,modulename text, time text, sync text)"
        
        let result_accessloglist = self.db.execute(SQL_DB_CREATE_ACCESSLOGLIST, parameters: nil)
        
        //客户通讯录日志
        let SQL_DB_CREATE_CUSTOMERLOGLIST = "CREATE TABLE IF NOT EXISTS \(Config.TableName.CustomerLogList) ( id INTEGER primary key AUTOINCREMENT, user text, module text, customerid text, phonenumber text, type text, startdatetime text, enddatetime text, duration text, sync text)"
        
        let result_customerloglist = self.db.execute(SQL_DB_CREATE_CUSTOMERLOGLIST, parameters: nil)
        
        return Int(result_mainmenulist + result_inneraddresslist + result_inneraddressdeptlist + result_accessloglist + result_customeraddresslist + result_customeraddresslist_group + result_customerloglist)
        
    }
    
    func checkTable(tablename:String) -> Int{
        
        // 判断数据库中有没有对应的表               
        let sql = "SELECT count(*) AS NUM FROM sqlite_master WHERE type='table' AND name='\(tablename)'";
        let data = self.db.query(sql)
        let row = data[0]
        let result = row["NUM"]?.asInt()
        //println("----checkTable \(tablename)--------count = \(Int(result!) ?? 0)-----")
        return Int(result!)
        
    }
    
    func dropTable(tablename:String) -> Int{
        //println("----dropTable \(tablename)---------------")
        //删除指定表
        let sql = "DROP TABLE \(tablename)";
        let result = self.db.execute(sql, parameters: nil)
        return Int(result)
    }
    
    //func queryTable(tablename:String,query:String,paralist:[String]?) -> Int{
    
    //    let data = self.db.query("SELECT * FROM \(tablename) WHERE \(query)", parameters:paralist)
    //let data = self.db.query("SELECT * FROM \(tablename) ", parameters:paralist)
    
    //for (index, row ) in enumerate(data) {
    //    println("\(index) ===\(row)")
    
    //}
    //     println("----queryTable \(tablename) count \(data.count)-------------")
    //     return data
    //}
    //=============MainNemuList=====================================================
    func syncMainMenuList(itemlist:NSMutableArray) -> Int{
        //var index = 0
        let updatetime = Util.getCurDateString()
        var sql = ""
        var updatesql = ""
        var sqlresult:CInt = 0
        var result = 0
        for (index, it) in itemlist.enumerate() {
            let item = it as! MainMenuItemBO
            
            sql = "REPLACE INTO \(Config.TableName.MainMenuList) (id, itemtext, uri, class, offline, itemimage, showindex, updatetime)"
                + "VALUES ('\(item.id)', '\(item.name)', '\(item.uri)', '\(item.classname)', '\(item.offline)', '\(item.itemimage)', \(index),'\(updatetime)')"
            sqlresult = self.db.execute(sql, parameters: nil)
            //println("----Insert \(item.name) -------- status = \(sqlresult)---------")
            
            result += (sqlresult == 0 ? 0 : 1)
        }
        
        sql = "DELETE FROM \(Config.TableName.MainMenuList) WHERE updatetime <> '\(updatetime)'"
        sqlresult = self.db.execute(sql, parameters: nil)
        
        //println("-- syncMainMenuList count = \(sqlresult)------------------")
        return result
    }
    
    func queryMainMenuList(query:String,paralist:[String]?) -> NSMutableArray?{
        let userInfo = NSMutableArray()
        let datalist = self.db.query("SELECT * FROM \(Config.TableName.MainMenuList) WHERE \(query)", parameters:paralist)
        
        if datalist.isEmpty {
            return nil
        } else{
            for (index, elem ) in datalist.enumerate() {
                
                let mainMenuItemBO:MainMenuItemBO = MainMenuItemBO()
                mainMenuItemBO.id = elem["id"]?.asString() ?? ""
                mainMenuItemBO.name = elem["itemtext"]?.asString() ?? ""
                mainMenuItemBO.itemimage = elem["itemimage"]?.asString() ?? ""
                mainMenuItemBO.classname = elem["class"]?.asString() ?? ""
                mainMenuItemBO.uri = elem["uri"]?.asString() ?? ""
                mainMenuItemBO.id = elem["id"]?.asString() ?? ""
                mainMenuItemBO.offline = elem["offl"]?.asString() ?? ""
                //mainMenuItemBO.initWithDic(dict as NSDictionary)
                userInfo.addObject(mainMenuItemBO)
            }
            return userInfo
        }
    }
    //===========================================================================
    
    //==========================================InnerAddressList====================
    
    func syncInnerAddressList(itemlist:NSArray) -> Int{
        //var index = 0
        var result = 0
        dispatch_async(self.queue1,{
            let updatetime = Util.getCurDateString()
            var sql = ""
            var updatesql = ""
            var sqlresult:CInt = 0
            
            for (index, it) in itemlist.enumerate() {
                let item = it as! InnerAddressItem
                sql = "REPLACE INTO \(Config.TableName.InnerAddressList) (empid , dept, name, mobile, linetel, mobiletelecom , mobiletelecom1, mobile1, othertel, homephone, researchteam, msn, pic, query,showindex , updatetime)"
                    + "VALUES ('\(item.empid)', '\(item.dept)', '\(item.name)', '\(item.mobile)', '\(item.linetel)', '\(item.mobiletelecom)', '\(item.mobiletelecom1)', '\(item.mobile1)', '\(item.othertel)', '\(item.homephone)', '\(item.researchteam)', '\(item.msn)', '\(item.pic)', '\(item.query)', '\(String(index))','\(updatetime)')"
                sqlresult = self.db.execute(sql, parameters: nil)
                //println("----Insert \(item.name) -------- status = \(sqlresult)---------")
                
                result += (sqlresult == 0 ? 0 : 1)
            }
            
            sql = "DELETE FROM \(Config.TableName.InnerAddressList) WHERE updatetime <> '\(updatetime)'"
            sqlresult = self.db.execute(sql, parameters: nil)
            //println("-- syncMainInnerAddressList count = \(result)------------------")
            
        })
        return result
    }
    
    func queryInnerAddressList(query:String,paralist:[String]?) -> NSMutableArray?{
        let userInfo = NSMutableArray()
        let datalist = self.db.query("SELECT * FROM \(Config.TableName.InnerAddressList) WHERE \(query)", parameters:paralist)
        
        if datalist.isEmpty {
            return nil
        } else{
            for (index, elem ) in datalist.enumerate() {
                
                let innerAddressItem:InnerAddressItem = InnerAddressItem()
                innerAddressItem.dept = elem["dept"]?.asString() ?? ""
                innerAddressItem.name = elem["name"]?.asString() ?? ""
                innerAddressItem.mobile = elem["mobile"]?.asString() ?? ""
                innerAddressItem.linetel = elem["linetel"]?.asString() ?? ""
                innerAddressItem.empid = elem["empid"]?.asString() ?? ""
                innerAddressItem.mobiletelecom = elem["mobiletelecom"]?.asString() ?? ""
                innerAddressItem.mobiletelecom1 = elem["mobiletelecom1"]?.asString() ?? ""
                
                innerAddressItem.mobile1 = elem["mobile1"]?.asString() ?? ""
                innerAddressItem.othertel = elem["othertel"]?.asString() ?? ""
                innerAddressItem.homephone = elem["homephone"]?.asString() ?? ""
                innerAddressItem.researchteam = elem["researchteam"]?.asString() ?? ""
                innerAddressItem.msn = elem["msn"]?.asString() ?? ""
                innerAddressItem.pic = elem["pic"]?.asString() ?? ""
                innerAddressItem.query = elem["query"]?.asString() ?? ""
                
                userInfo.addObject(innerAddressItem)
            }
            return userInfo
        }
    }
    
    
    //==============================================================================
    //==========InnerAddressDeptList==================================================
    func syncInnerAddressDeptList(itemlist:NSArray) -> Int{
        //var index = 0
        var result = 0
        dispatch_async(self.queue1,{
            let updatetime = Util.getCurDateString()
            var sql = ""
            var updatesql = ""
            var sqlresult:CInt = 0
            
            for (index, it) in itemlist.enumerate() {
                let item = it as! InnerAddressDeptItem
                
                sql = "REPLACE INTO \(Config.TableName.InnerAddressDeptList) (name, showindex , updatetime)"
                    + "VALUES ('\(item.name)','\(String(index))','\(updatetime)')"
                sqlresult = self.db.execute(sql, parameters: nil)
                //println("----Insert \(item.name) -------- status = \(sqlresult)---------")
                
                result += (sqlresult == 0 ? 0 : 1)
            }
            
            sql = "DELETE FROM \(Config.TableName.InnerAddressDeptList) WHERE updatetime <> '\(updatetime)'"
            sqlresult = self.db.execute(sql, parameters: nil)
        })
        //println("-- syncMainInnerAddressDeptList count = \(result)------------------")
        return result
    }
    
    
    func queryInnerAddressDeptList(query:String,paralist:[String]?) -> NSMutableArray?{
        let userInfo = NSMutableArray()
        let datalist = self.db.query("SELECT * FROM \(Config.TableName.InnerAddressDeptList) WHERE \(query)", parameters:paralist)
        
        if datalist.isEmpty {
            return nil
        } else{
            for (index, elem ) in datalist.enumerate() {
                
                let innerAddressDeptItem:InnerAddressDeptItem = InnerAddressDeptItem()
                innerAddressDeptItem.name = elem["name"]?.asString() ?? ""
                
                userInfo.addObject(innerAddressDeptItem)
            }
            return userInfo
        }
    }
    
    
    //==================================================================================
    
    
    
    
    //==========================================CustomerAddressList====================
    
    func syncCustomerAddressList(itemlist:NSArray) -> Int{
        //var index = 0
        var result = 0
        //queue1
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
        dispatch_async(self.queue1,{
            print(itemlist.count)
            let updatetime = Util.getCurDateString()
            var sql = ""
            var updatesql = ""
            var sqlresult:CInt = 0
            
            for (index, it) in itemlist.enumerate() {
                let item = it as! CustomerAddressItem
                sql = "REPLACE INTO \(Config.TableName.CustomerAddressList) (customerid , comp , groupname , name , mobile , linetel , comptel , email, important , importantid , level , managerlist , sex , jobtitle , custlevel , status ,  query ,showindex , updatetime)"
                    + "VALUES ('\(item.customerid)', '\(item.comp)', '\(item.group)', '\(item.name)', '\(item.mobile)', '\(item.linetel)', '\(item.comptel)', '\(item.email)','\(item.important)', '\(item.importantid)', '\(item.level)', '\(item.managerlist)', '\(item.sex)','\(item.jobtitle)', '\(item.custlevel)','\(item.status)', '\(item.query)', '\(String(index))','\(updatetime)')"
                sqlresult = self.db.execute(sql, parameters: nil)
                //println("----Insert \(item.name) -------- status = \(sqlresult)---------")
                
                result += (sqlresult == 0 ? 0 : 1)
            }
            sql = "DELETE FROM \(Config.TableName.CustomerAddressList) WHERE updatetime <> '\(updatetime)'"
            sqlresult = self.db.execute(sql, parameters: nil)
            print("-- syncMainCustomerAddressList count = \(result)------------------")
            
        })
        return result
        
    }
    
    func queryCustomerAddressList(query:String,paralist:[String]?) -> NSMutableArray?{
        var userInfo:NSMutableArray? = NSMutableArray()
        //dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
        
        
        let datalist = self.db.query("SELECT * FROM \(Config.TableName.CustomerAddressList) WHERE \(query)", parameters:paralist)
        if datalist.isEmpty {
            userInfo = nil
            //return nil
        } else{
            for (index, elem ) in datalist.enumerate() {
                
                let customerAddressItem:CustomerAddressItem = CustomerAddressItem()
                customerAddressItem.customerid = elem["customerid"]?.asString() ?? ""
                customerAddressItem.comp = elem["comp"]?.asString() ?? ""
                customerAddressItem.group = elem["groupname"]?.asString() ?? ""
                customerAddressItem.name = elem["name"]?.asString() ?? ""
                customerAddressItem.mobile = elem["mobile"]?.asString() ?? ""
                customerAddressItem.linetel = elem["linetel"]?.asString() ?? ""
                customerAddressItem.comptel = elem["comptel"]?.asString() ?? ""
                
                customerAddressItem.email = elem["email"]?.asString() ?? ""
                customerAddressItem.important = elem["important"]?.asString() ?? ""
                customerAddressItem.importantid = elem["importantid"]?.asString() ?? ""
                customerAddressItem.managerlist = elem["managerlist"]?.asString() ?? ""
                customerAddressItem.sex = elem["sex"]?.asString() ?? ""
                customerAddressItem.jobtitle = elem["jobtitle"]?.asString() ?? ""
                customerAddressItem.custlevel = elem["custlevel"]?.asString() ?? ""
                customerAddressItem.status = elem["status"]?.asString() ?? ""
                customerAddressItem.query = elem["query"]?.asString() ?? ""
                
                userInfo!.addObject(customerAddressItem)
            }
            //return userInfo
        }
        //})
        return userInfo
    }
    
    
    //==============================================================================
    
    //==========CustomerAddressGroupList==================================================
    func syncCustomerAddressGroupList(itemlist:NSArray) -> Int{
        //var index = 0
        var result = 0
        //dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
        dispatch_async(self.queue1,{
            let updatetime = Util.getCurDateString()
            var sql = ""
            var updatesql = ""
            var sqlresult:CInt = 0
            
            for (index, it) in itemlist.enumerate() {
                let item = it as! CustomerAddressGroupItem
                
                sql = "REPLACE INTO \(Config.TableName.CustomerAddressGroupList) (name, level, showindex , updatetime)"
                    + "VALUES ('\(item.name)','\(item.level)','\(String(index))','\(updatetime)')"
                sqlresult = self.db.execute(sql, parameters: nil)
                //println("----Insert \(item.name) -------- status = \(sqlresult)---------")
                
                result += (sqlresult == 0 ? 0 : 1)
            }
            
            sql = "DELETE FROM \(Config.TableName.CustomerAddressGroupList) WHERE updatetime <> '\(updatetime)'"
            sqlresult = self.db.execute(sql, parameters: nil)
            
            //println("-- syncMainCustomerAddressGroupList count = \(result)------------------")
        })
        
        return result
    }
    
    
    func queryCustomerAddressGroupList(query:String,paralist:[String]?) -> NSMutableArray?{
        
        var userInfo:NSMutableArray? = NSMutableArray()
        //dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
        
        let datalist = self.db.query("SELECT * FROM \(Config.TableName.CustomerAddressGroupList) WHERE \(query)", parameters:paralist)
        
        if datalist.isEmpty {
            userInfo = nil
            //return nil
        } else{
            for (index, elem ) in datalist.enumerate() {
                
                let customerAddressGroupItem:CustomerAddressGroupItem = CustomerAddressGroupItem()
                customerAddressGroupItem.name = elem["name"]?.asString() ?? ""
                customerAddressGroupItem.level = elem["level"]?.asString() ?? ""
                userInfo!.addObject(customerAddressGroupItem)
            }
            //return userInfo
        }
        //})
        return userInfo
    }
    
    
    //==================================================================================
    
    //=======================AccessLogList================================================
    
    func syncAccessLogItem(item:AccessLogItem) -> Int{
        
        var sql = ""
        var sqlresult:CInt = 0
        //id 自增长，所以增加时不用传值
        sql = "REPLACE INTO \(Config.TableName.AccessLogList) (userid, type, online, moduleid, modulename, time, sync)"
            + "VALUES ('\(item.userid)','\(item.type))','\(item.online)','\(item.moduleid)','\(item.modulename)','\(item.time)','\(item.sync)')"
        sqlresult = self.db.execute(sql, parameters: nil)
        //println("----Insert \(item.userid) -------- status = \(sqlresult)---------")
        
        return Int(sqlresult)
    }
    
    func queryAccessLogList(query:String,paralist:[String]?) -> NSMutableArray?{
        let userInfo = NSMutableArray()
        let datalist = self.db.query("SELECT * FROM \(Config.TableName.AccessLogList) WHERE \(query)", parameters:paralist)
        
        if datalist.isEmpty {
            return nil
        } else{
            for (index, elem ) in datalist.enumerate() {
                
                let accessLogItem:AccessLogItem = AccessLogItem()
                accessLogItem.id = elem["id"]?.asInt() ?? 0
                accessLogItem.userid = elem["userid"]?.asString() ?? ""
                accessLogItem.type = elem["type"]?.asString() ?? ""
                accessLogItem.online = elem["online"]?.asString() ?? ""
                accessLogItem.moduleid = elem["moduleid"]?.asString() ?? ""
                accessLogItem.modulename = elem["modulename"]?.asString() ?? ""
                accessLogItem.time = elem["time"]?.asString() ?? ""
                accessLogItem.sync = elem["sync"]?.asString() ?? ""
                
                userInfo.addObject(accessLogItem)
            }
            return userInfo
        }
    } 
    
    func markAccessLogListSync(itemlist:NSArray) -> Int{
        //var index = 0
        var updatetime = Util.getCurDateString()
        var sql = ""
        var sqlresult:CInt = 0
        var result = 0
        for (index, it) in itemlist.enumerate() {
            let item = it as! AccessLogItem
            
            sql = "UPDATE \(Config.TableName.AccessLogList) SET SYNC = 'Y' WHERE id = \(item.id)"
            sqlresult = self.db.execute(sql, parameters: nil)
            //println("----Update \(item.userid) -------- status = \(sqlresult)---------")
            
            result += (sqlresult == 0 ? 0 : 1)
        }
        
        return result
    }
    //====================================================================================
    
    
    //=======================CustomerLogList================================================
    
    func syncCustomerLogItem(item:CustomerLogItem) -> Int{
        
        var sql = ""
        var sqlresult:CInt = 0
        //id 自增长，所以增加时不用传值
        //id INTEGER primary key AUTOINCREMENT, user text, module text, customerid text, phonenumber text, type text, startdatetime text, enddatetime text, duration text, sync text
        sql = "REPLACE INTO \(Config.TableName.CustomerLogList) (user, module, customerid, phonenumber, type, startdatetime, enddatetime, duration, sync)"
            + "VALUES ('\(item.user)','\(item.module))','\(item.customerid)','\(item.phonenumber)','\(item.type)','\(item.startdatetime)','\(item.enddatetime)','\(item.duration)','\(item.sync)')"
        sqlresult = self.db.execute(sql, parameters: nil)
        //println("----Insert \(item.userid) -------- status = \(sqlresult)---------")
        
        return Int(sqlresult)
    }
    
    func queryCustomerLogList(query:String,paralist:[String]?) -> NSMutableArray?{
        let userInfo = NSMutableArray()
        let datalist = self.db.query("SELECT * FROM \(Config.TableName.CustomerLogList) WHERE \(query)", parameters:paralist)
        
        if datalist.isEmpty {
            return nil
        } else{
            for (index, elem ) in datalist.enumerate() {
                
                let customerLogItem:CustomerLogItem = CustomerLogItem()
                customerLogItem.id = elem["id"]?.asInt() ?? 0
                customerLogItem.user = elem["user"]?.asString() ?? ""
                customerLogItem.module = elem["module"]?.asString() ?? ""
                customerLogItem.customerid = elem["customerid"]?.asString() ?? ""
                customerLogItem.phonenumber = elem["phonenumber"]?.asString() ?? ""
                customerLogItem.type = elem["type"]?.asString() ?? ""
                customerLogItem.startdatetime = elem["startdatetime"]?.asString() ?? ""
                customerLogItem.enddatetime = elem["enddatetime"]?.asString() ?? ""
                customerLogItem.duration = elem["duration"]?.asString() ?? ""
                customerLogItem.sync = elem["sync"]?.asString() ?? ""
                
                userInfo.addObject(customerLogItem)
            }
            return userInfo
        }
    } 
    
    func markCustomerLogListSync(itemlist:NSArray) -> Int{
        //var index = 0
        var updatetime = Util.getCurDateString()
        var sql = ""
        var sqlresult:CInt = 0
        var result = 0
        for (index, it) in itemlist.enumerate() {
            let item = it as! CustomerLogItem
            
            sql = "UPDATE \(Config.TableName.CustomerLogList) SET SYNC = 'Y' WHERE id = \(item.id)"
            sqlresult = self.db.execute(sql, parameters: nil)
            //println("----Update \(item.userid) -------- status = \(sqlresult)---------")
            
            result += (sqlresult == 0 ? 0 : 1)
        }
        
        return result
    }
    //====================================================================================

}


