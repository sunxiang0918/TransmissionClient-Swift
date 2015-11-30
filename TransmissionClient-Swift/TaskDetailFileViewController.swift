//
//  TaskDetailFileViewController.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/28.
//  Copyright © 2015年 SUN. All rights reserved.
//

import UIKit

class TaskDetailFileViewController : UITableViewController,TaskDetailProtocol {
    
    private var _taskDetail:TaskDetailVO!
    
    var taskDetail:TaskDetailVO {
        get{
            return _taskDetail
        }
        set(newValue){
            _taskDetail = newValue
        }
    }
    
    override func viewDidLoad() {
        let nib=UINib(nibName: "TaskDetailFileTavleViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "taskDetailFileTavleViewCell")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let _files = _taskDetail.files
        
        guard let files = _files else {
            return 0
        }
        
        return files.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var tmp = tableView.dequeueReusableCellWithIdentifier("taskDetailFileTavleViewCell") as? TaskDetailFileTavleViewCell
        
        if (tmp == nil) {
            tmp = TaskDetailFileTavleViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "taskDetailFileTavleViewCell")
        }
        
        let _file = _taskDetail.files?[indexPath.row]
        
        guard let file = _file else {
            return tmp!
        }
        
        
        var name = ""
        for _ in 0..<file.layer {
            name = name + "    "
        }
        name = name + file.name
        
        tmp?.fileNameLabel.text = name
        
        //1.20 GB of 1.20 GB (100%)
        tmp?.statusLabel.text = "\(SpeedStringFormatter.formatSpeedToString(file.bytesCompleted)) of \(SpeedStringFormatter.formatSpeedToString(file.length)) (\(Float(file.bytesCompleted)/Float(file.length) * 100)%)"
        
        if !file.wanted {
            tmp?.backgroundColor = UIColor.lightGrayColor()
        }else {
            tmp?.backgroundColor = UIColor.clearColor()
        }
        
        switch file.priority {
        case -1:
            tmp?.upButton.selected = false
            tmp?.norButton.selected = false
            tmp?.downButton.selected = true
            break
        case 0:
            tmp?.upButton.selected = false
            tmp?.norButton.selected = true
            tmp?.downButton.selected = false
            break
        case 1:
            tmp?.upButton.selected = true
            tmp?.norButton.selected = false
            tmp?.downButton.selected = false
            break
        default:
            tmp?.upButton.selected = false
            tmp?.norButton.selected = true
            tmp?.downButton.selected = false
            break
        }
        
        return tmp!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    
}
