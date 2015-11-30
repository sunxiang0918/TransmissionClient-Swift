//
//  TaskDetailFileTavleViewCell.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/28.
//  Copyright © 2015年 SUN. All rights reserved.
//

import UIKit

class TaskDetailFileTavleViewCell: UITableViewCell {
    
    @IBOutlet weak var fileNameLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var upButton: UIButton!
    
    @IBOutlet weak var norButton: UIButton!
    
    @IBOutlet weak var downButton: UIButton!
    
    @IBOutlet weak var images: UIImageView!
    
    @IBOutlet weak var leadingDocument: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}