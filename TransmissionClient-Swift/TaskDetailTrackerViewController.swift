//
//  TaskDetailTrackerViewController.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/28.
//  Copyright © 2015年 SUN. All rights reserved.
//

import UIKit

class TaskDetailTrackerViewController : UITableViewController,TaskDetailProtocol {
    
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
        let nib=UINib(nibName: "TaskDetailTrackerTableViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "taskDetailTrackerTableViewCell")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let _trackers = _taskDetail.trackerStats
        
        guard let trackers = _trackers else {
            return 0
        }
        
        return trackers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var tmp = tableView.dequeueReusableCellWithIdentifier("taskDetailTrackerTableViewCell") as? TaskDetailTrackerTableViewCell
        
        if (tmp == nil) {
            tmp = TaskDetailTrackerTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "taskDetailTrackerTableViewCell")
        }
        
        let _tracker = _taskDetail.trackerStats?[indexPath.row]
        
        guard let tracker = _tracker else {
            return tmp!
        }
        
        tmp?.hostLabel.text = tracker.host
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if tracker.lastAnnounceSucceeded {
            tmp?.lastAnnounceLabel.text = formatter.stringFromDate(tracker.lastAnnounceTime)
        }else {
            tmp?.lastAnnounceLabel.text = "上次获取播报失败"
        }
        
        let nextTime = Float(tracker.nextAnnounceTime.timeIntervalSinceDate(NSDate()))
        if  nextTime < 0 {
            tmp?.nextAnnounceLabel.text = "播报已在队列"
        }else{
            tmp?.nextAnnounceLabel.text = SpeedStringFormatter.clcaultTimesToString(nextTime)
        }
        
        
        tmp?.lastScrapeLabel.text = formatter.stringFromDate(tracker.lastScrapeStartTime)
        
        tmp?.seedersLabel.text = "\(tracker.seederCount)"
        
        tmp?.leechersLabel.text = "\(tracker.leecherCount)"
        
        tmp?.downloadsLabel.text = "\(tracker.downloadCount)"
        
        return tmp!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 130
    }
}
