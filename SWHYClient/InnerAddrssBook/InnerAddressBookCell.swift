//
//  InnerAddressBookCell.swift
//  SWHYClient
//
//  Created by sunny on 3/24/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//

import UIKit

class InnerAddressBookCell: UITableViewCell {
 

    @IBOutlet weak var icon: UIImageView!
        
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var dept: UILabel!
    @IBOutlet weak var telcom_s: UILabel!
    @IBOutlet weak var mobile_s: UILabel!

    @IBOutlet weak var btntelcom: UIButton!
    @IBOutlet weak var btnmobile: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
