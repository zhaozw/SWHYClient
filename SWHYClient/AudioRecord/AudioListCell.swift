//
//  InnerAddressBookCell.swift
//  SWHYClient
//
//  Created by sunny on 3/24/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//

import UIKit

class AudioListCell: UITableViewCell {
    
    
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var createtime: UILabel!
    @IBOutlet weak var duration: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
