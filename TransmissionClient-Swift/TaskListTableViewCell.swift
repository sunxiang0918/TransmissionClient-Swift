//
//  TaskListTableCellView.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/25.
//  Copyright © 2015年 SUN. All rights reserved.
//

import UIKit

class TaskListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}