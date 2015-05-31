//
//  UIViewControllerExtension.swift
//  SWHYClient
//
//  Created by sunny on 5/13/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func setNavigationBarItem() {
        //self.addLeftBarButtonWithImage(UIImage(named: "ic_notifications_black")!)
        self.addRightBarButtonWithImage(UIImage(named: "ic_menu_black")!)
        //self.slideMenuController()?.removeLeftGestures()
        self.slideMenuController()?.removeRightGestures()
        //self.slideMenuController()?.addLeftGestures()
        self.slideMenuController()?.addRightGestures()
    }
    
    func removeNavigationBarItem() {
        //self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        //self.slideMenuController()?.removeLeftGestures()
        self.slideMenuController()?.removeRightGestures()
    }
}