//
//  CustomerAddressBookHeader.swift
//  SWHYClient
//
//  Created by sunny on 5/27/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//

//
//  InnerAddressBookHeader.swift
//  SWHYClient
//
//  Created by sunny on 4/2/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//

import UIKit

// 该协议将被用户组的委托实现； 当用户组被打开/关闭时，它将通知发送给委托，来告知Xcode调用何方法
protocol CustomerAddressBookHeaderDelegate: NSObjectProtocol {
    func customerAddressBookHeader(customerAddressBookHeader: CustomerAddressBookHeader, sectionOpened: Int)
    func customerAddressBookHeader(customerAddressBookHeader: CustomerAddressBookHeader, sectionClosed: Int)
}

class CustomerAddressBookHeader: UITableViewHeaderFooterView {
    @IBOutlet weak var LblTitle: UILabel!
    @IBOutlet weak var ImgNarrow: UIImageView!
    //@IBOutlet weak var BtnDisclosure: UIButton!
    
    var delegate: CustomerAddressBookHeaderDelegate!
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
        let tapGesture = UITapGestureRecognizer(target: self, action: "btnTap:")
        self.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func btnTap(sender: UITapGestureRecognizer) {
        //print("   click    ")
        self.toggleOpen(true)
    }
    
    func toggleOpen(userAction: Bool) {
        //BtnDisclosure.selected = !BtnDisclosure.selected
        // 如果userAction传入的值为真，将给委托传递相应的消息
        if userAction {
            if HeaderOpen {
                //self.ImgNarrow.image = UIImage(named:"narrow_right")
                delegate.customerAddressBookHeader(self, sectionClosed: section)
            }
            else {
                //self.ImgNarrow.image = UIImage(named:"narrow_down")
                delegate.customerAddressBookHeader(self, sectionOpened: section)
            }
        }
    }
}