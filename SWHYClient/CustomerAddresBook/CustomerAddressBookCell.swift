//
//  InnerAddressBookCell.swift
//  SWHYClient
//
//  Created by sunny on 3/24/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//

import UIKit

class CustomerAddressBookCell: UITableViewCell {
 
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var lblName: UILabel!

    @IBOutlet weak var lblComp: UILabel!
    @IBOutlet var btnMobile: MKButton!
    @IBOutlet var btnLinetel: MKButton!
       
    //var btn:MKButton
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
