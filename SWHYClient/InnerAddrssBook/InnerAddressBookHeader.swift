//
//  InnerAddressBookHeader.swift
//  SWHYClient
//
//  Created by sunny on 4/2/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//

import UIKit

// 该协议将被用户组的委托实现； 当用户组被打开/关闭时，它将通知发送给委托，来告知Xcode调用何方法
protocol InnerAddressBookHeaderDelegate: NSObjectProtocol {
    func innerAddressBookHeader(innerAddressBookHeader: InnerAddressBookHeader, sectionOpened: Int)
    func innerAddressBookHeader(innerAddressBookHeader: InnerAddressBookHeader, sectionClosed: Int)
}

class InnerAddressBookHeader: UITableViewHeaderFooterView {
    @IBOutlet weak var LblTitle: UILabel!
    @IBOutlet weak var ImgNarrow: UIImageView!
    //@IBOutlet weak var BtnDisclosure: UIButton!
    
    var delegate: InnerAddressBookHeaderDelegate!
    var section: Int!
    //var HeaderOpen: Bool = false  // 标记HeaderView是否展开
    var HeaderOpen: Bool = false {
        willSet(newTotalSteps) {
            //println("About to set totalSteps to \(newTotalSteps)")
        }
        didSet {
            //if totalSteps > oldValue  {
            //    println("Added \(totalSteps - oldValue) steps")
            //}
            //println("oldvalue=\(oldValue)  newValue = \(HeaderOpen)")
        }
    }
    
    override func awakeFromNib() {
        // 设置disclosure 按钮的图片（被打开）
        //self.BtnDisclosure.setImage(UIImage(named: "carat-open"), forState: UIControlState.Selected)
        
        // 单击手势识别
        var tapGesture = UITapGestureRecognizer(target: self, action: "btnTap:")
        self.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func btnTap(sender: UITapGestureRecognizer) {
        println("   click    ")
        self.toggleOpen(true)
    }
    
    func toggleOpen(userAction: Bool) {
        //BtnDisclosure.selected = !BtnDisclosure.selected
        // 如果userAction传入的值为真，将给委托传递相应的消息
        if userAction {
            if HeaderOpen {
                //self.ImgNarrow.image = UIImage(named:"narrow_right")
                delegate.innerAddressBookHeader(self, sectionClosed: section)
            }
            else {
                //self.ImgNarrow.image = UIImage(named:"narrow_down")
                delegate.innerAddressBookHeader(self, sectionOpened: section)
            }
        }
    }
}