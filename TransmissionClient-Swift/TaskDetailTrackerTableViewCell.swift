//
//  TaskDetailTrackerTableViewCell.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/28.
//  Copyright © 2015年 SUN. All rights reserved.
//

import UIKit

class TaskDetailTrackerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var hostLabel: UILabel!
    
    @IBOutlet weak var lastAnnounceLabel: UILabel!
    
    @IBOutlet weak var nextAnnounceLabel: UILabel!
    
    @IBOutlet weak var lastScrapeLabel: UILabel!
    
    @IBOutlet weak var seedersLabel: UILabel!
    
    @IBOutlet weak var leechersLabel: UILabel!
    
    @IBOutlet weak var downloadsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}