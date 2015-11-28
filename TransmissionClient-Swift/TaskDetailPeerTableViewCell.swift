//
//  TaskDetailPeerTableViewCell.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/28.
//  Copyright © 2015年 SUN. All rights reserved.
//

import UIKit

class TaskDetailPeerTableViewCell: UITableViewCell {

    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var flagLabel: UILabel!
    
    @IBOutlet weak var processLabel: UILabel!
    
    @IBOutlet weak var clientLabel: UILabel!
    
    @IBOutlet weak var uploadLabel: UILabel!
    
    @IBOutlet weak var downloadLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}