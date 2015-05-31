//
//  Util.swift
//  SWHYClient
//
//  Created by sunny on 4/7/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//

import Foundation
import UIKit

class Util{
    
    class func getScreen() -> CGRect {
        return UIScreen.mainScreen().bounds
    }
    
    class func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
    class func getCurDateString() -> String{
        var nowDate = NSDate()
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var dateString = formatter.stringFromDate(nowDate)
        return dateString
    
    }
    
    class func applicationDocumentPath() -> String {
            // 获取程序的 document
            let application = NSSearchPathForDirectoriesInDomains (.DocumentDirectory, .UserDomainMask, true )
            
            let documentPathString = application[0] as! String
            
            return documentPathString
            
    }
    
    // 拼接文件路径
    class func applicationFilePath(fileName: String ,directory: String? ) -> String  {
        
        var docuPath = Util.applicationDocumentPath()
        
        if directory == nil {
            
            return docuPath.stringByAppendingPathComponent(fileName)
            
        } else {
            
            return docuPath.stringByAppendingPathComponent("\(directory)/\(fileName)" )
            
        }
        
    }
    
    // 指定路径下是否存在 特定 “ 文件 ” 或 “ 文件夹 ”
    class func applicationFileExistAtPath(fileTypeDirectory: Bool ,fileName: String ,directory: String ) -> Bool  {
       
        var filePath = Util.applicationFilePath(fileName, directory:directory)
        
        if fileTypeDirectory { // 普通文件（图片、 plist 、 txt 等等）
            
            return NSFileManager.defaultManager().fileExistsAtPath (filePath)
            
        } else { // 文件夹
            
            //UnsafeMutablePointer<ObjCBool> 不能再直接使用   Bool  类型
            
            var isDir : ObjCBool = false
            
            return NSFileManager.defaultManager().fileExistsAtPath(filePath, isDirectory: &isDir)
            
        }
        
    }
    
    // 创建文件 或 文件夹在指定路径下
    class func applicationCreatFileAtPath(#fileTypeDirectory: Bool ,fileName: String ,directory: String? ,content:NSData?) -> Bool {
         println("  do save  ")
        var filePath = Util.applicationFilePath (fileName, directory: directory)
        println(filePath)
        if fileTypeDirectory { // 普通文件（图片、 plist 、 txt 等等）
            return NSFileManager.defaultManager().createDirectoryAtPath(filePath, withIntermediateDirectories: true , attributes: nil , error: nil )
        } else { // 文件夹
            return NSFileManager.defaultManager().createFileAtPath (filePath, contents: content , attributes: nil )
            
        }
        
    }
    
    // 移除指定路径下地文件中
    
    class func applicationRemoveFileAtPath(fileName: String ,directory: String ) -> Bool {
        
        var filePath = Util.applicationFilePath (fileName, directory: directory)
        
        return NSFileManager.defaultManager().removeItemAtPath(filePath, error: nil )
        
    }
    
    // 向指定路径下地文件中写入数据
    
    class func applicationWriteDataToFileAtPath(#dataTypeArray: Bool ,content: AnyObject ,fileName: String ,directory: String ) -> Bool {
       
        var filePath = Util.applicationFilePath (fileName, directory: directory)
        
        if dataTypeArray {
                        return (content as! NSArray ).writeToFile (filePath, atomically: true )
            
        } else {
           
            return (content as! NSDictionary ).writeToFile (filePath, atomically: true )
            
        }
        
    }
    
    
    // 读取特定文件中数据（如： plist 、 text 等）
    
    class func applicationReadDataToFileAtPath(#dataTypeArray: Bool ,fileName: String ,directory: String ) -> AnyObject {
        
        var filePath = Util.applicationFilePath (fileName, directory: directory)
        
        if dataTypeArray {
            
            return NSArray (contentsOfFile: filePath)!
            
        } else {
            
            return NSDictionary (contentsOfFile: filePath)!
            
        }
        
    }
    
    // 读取文件夹中所有子文件（如： photo 文件夹中所有 image ）
    
    class func applicationReadFileOfDirectoryAtPath(fileName: String ,directory: String ) -> AnyObject {
        
        var filePath = Util.applicationFilePath (fileName, directory: directory)
        
        var content = NSFileManager.defaultManager().contentsOfDirectoryAtPath(filePath, error: nil )
        
        return content!
        
    }
    
}