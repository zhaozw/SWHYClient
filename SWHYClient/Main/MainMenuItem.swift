//
//  MainMenuItemXib.swift
//  SWHY_Moblie
//
//  Created by sunny on 3/11/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//

import Foundation
import UIKit

class MainMenuItem:UIView{
    
    
    @IBAction func iconClick(sender:AnyObject){
        
    }
    
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    
    func FillMenu(mainMenuItemBO:MainMenuItemBO){
        label.text = mainMenuItemBO.name
        //icon.image = UIImage(data: mainMenuItemBO.icon)
        if let url:NSURL = NSURL(string:mainMenuItemBO.itemimage){
            
            //这里应该直接加载对象里的图片DATA
            icon.hnk_setImageFromURL(url)   //简单方式
            //NSData *imageData = UIImagePNGRepresentation(icon.image); 
            //icon.image.
            //以下用常规方式 ，以可以捕获网络图片加载错误
            //icon.hn
            
            /*
            icon.hnk_setImageFromURL(url, placeholder:icon.image, format: nil,failure:{ (NSError) -> Void in
                println("ERROR")
                //self.icon.hnk_setImageFromURL(defaulturl)
                self.icon.image = UIImage(named: "logo")
                }
                , success: { (image:UIImage) -> Void in
                    //println("SUCCESS")
                    self.icon.image = image
            })
            */
            //icon.hnk_setImageFromURL(<#url: NSURL!#>, placeholder: <#UIImage!#>, success: <#((UIImage!) -> Void)!##(UIImage!) -> Void#>, failure: <#((NSError!) -> Void)!##(NSError!) -> Void#>)

        }
        
    }
}
