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
        let nowDate = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.stringFromDate(nowDate)
        return dateString
    
    }
    class func getAppVersion() -> String{
       
        let infoDictionary = NSBundle.mainBundle().infoDictionary
        let majorVersion : AnyObject? = infoDictionary! ["CFBundleShortVersionString"]
        let minorVersion : AnyObject? = infoDictionary! ["CFBundleVersion"]
        let strMajorVersion = majorVersion as! String
        let strMinorVersion = minorVersion as! String
        return strMajorVersion + "." + strMinorVersion
        
    }
    class func applicationDocumentPath() -> String {
            // 获取程序的 document
            let application = NSSearchPathForDirectoriesInDomains (.DocumentDirectory, .UserDomainMask, true )
            
            let documentPathString = application[0] 
            
            return documentPathString
            
    }
    
    // 拼接文件路径
    class func applicationFilePath(fileName: String ,directory: String? ) -> String  {
        
        let docuPath = Util.applicationDocumentPath()
        
        if directory == nil {
            
            //return docuPath.stringByAppendingPathComponent(fileName)
            return docuPath.stringByAppendingString("/"+fileName)
        } else {
            
            //return docuPath.stringByAppendingPathComponent("\(directory)/\(fileName)" )
            return docuPath.stringByAppendingString("/"+"\(directory)/\(fileName)")
        }
        
    }
    
    // 指定路径下是否存在 特定 “ 文件 ” 或 “ 文件夹 ”
    class func applicationFileExistAtPath(fileTypeDirectory: Bool ,fileName: String ,directory: String ) -> Bool  {
       
        let filePath = Util.applicationFilePath(fileName, directory:directory)
        
        if fileTypeDirectory { // 普通文件（图片、 plist 、 txt 等等）
            
            return NSFileManager.defaultManager().fileExistsAtPath (filePath)
            
        } else { // 文件夹
            
            //UnsafeMutablePointer<ObjCBool> 不能再直接使用   Bool  类型
            
            var isDir : ObjCBool = false
            
            return NSFileManager.defaultManager().fileExistsAtPath(filePath, isDirectory: &isDir)
            
        }
        
    }
    
    // 创建文件 或 文件夹在指定路径下
    class func applicationCreatFileAtPath(fileTypeDirectory fileTypeDirectory: Bool ,fileName: String ,directory: String? ,content:NSData?) -> Bool {
         print("  do save  ")
        let filePath = Util.applicationFilePath (fileName, directory: directory)
        print(filePath)
        if fileTypeDirectory { // 普通文件（图片、 plist 、 txt 等等）
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(filePath, withIntermediateDirectories: true , attributes: nil )
                return true
            } catch _ {
                return false
            }
        } else { // 文件夹
            return NSFileManager.defaultManager().createFileAtPath (filePath, contents: content , attributes: nil )
            
        }
        
    }
    
    // 移除指定路径下地文件中
    
    class func applicationRemoveFileAtPath(fileName: String ,directory: String ) -> Bool {
        
        let filePath = Util.applicationFilePath (fileName, directory: directory)
        
        do {
            try NSFileManager.defaultManager().removeItemAtPath(filePath)
            return true
        } catch _ {
            return false
        }
        
    }
    
    // 向指定路径下地文件中写入数据
    
    class func applicationWriteDataToFileAtPath(dataTypeArray dataTypeArray: Bool ,content: AnyObject ,fileName: String ,directory: String ) -> Bool {
       
        let filePath = Util.applicationFilePath (fileName, directory: directory)
        
        if dataTypeArray {
                        return (content as! NSArray ).writeToFile (filePath, atomically: true )
            
        } else {
           
            return (content as! NSDictionary ).writeToFile (filePath, atomically: true )
            
        }
        
    }
    
    
    // 读取特定文件中数据（如： plist 、 text 等）
    
    class func applicationReadDataToFileAtPath(dataTypeArray dataTypeArray: Bool ,fileName: String ,directory: String ) -> AnyObject {
        
        let filePath = Util.applicationFilePath (fileName, directory: directory)
        
        if dataTypeArray {
            
            return NSArray (contentsOfFile: filePath)!
            
        } else {
            
            return NSDictionary (contentsOfFile: filePath)!
            
        }
        
    }
    
    // 读取文件夹中所有子文件（如： photo 文件夹中所有 image ）
    
    class func applicationReadFileOfDirectoryAtPath(fileName: String ,directory: String ) -> AnyObject {
        
        let filePath = Util.applicationFilePath (fileName, directory: directory)
        
        let content = try? NSFileManager.defaultManager().contentsOfDirectoryAtPath(filePath)
        
        return content!
        
    }
    
}