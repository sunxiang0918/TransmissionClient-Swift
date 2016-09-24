//
//  TaskDetailTrackerViewController.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/28.
//  Copyright © 2015年 SUN. All rights reserved.
//

import UIKit

class TaskDetailTrackerViewController : UITableViewController,TaskDetailProtocol {
    
    fileprivate var _taskDetail:TaskDetailVO!
    
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
        self.tableView.register(nib, forCellReuseIdentifier: "taskDetailTrackerTableViewCell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let _trackers = _taskDetail.trackerStats
        
        guard let trackers = _trackers else {
            return 0
        }
        
        return trackers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var tmp = tableView.dequeueReusableCell(withIdentifier: "taskDetailTrackerTableViewCell") as? TaskDetailTrackerTableViewCell
        
        if (tmp == nil) {
            tmp = TaskDetailTrackerTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "taskDetailTrackerTableViewCell")
        }
        
        let _tracker = _taskDetail.trackerStats?[(indexPath as NSIndexPath).row]
        
        guard let tracker = _tracker else {
            return tmp!
        }
        
        tmp?.hostLabel.text = tracker.host
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if tracker.lastAnnounceSucceeded {
            tmp?.lastAnnounceLabel.text = formatter.string(from: tracker.lastAnnounceTime as Date)
        }else {
            tmp?.lastAnnounceLabel.text = "上次获取播报失败"
        }
        
        let nextTime = Float(tracker.nextAnnounceTime.timeIntervalSince(Date()))
        if  nextTime < 0 {
            tmp?.nextAnnounceLabel.text = "播报已在队列"
        }else{
            tmp?.nextAnnounceLabel.text = SpeedStringFormatter.clcaultTimesToString(nextTime)
        }
        
        
        tmp?.lastScrapeLabel.text = formatter.string(from: tracker.lastScrapeStartTime as Date)
        
        tmp?.seedersLabel.text = "\(tracker.seederCount)"
        
        tmp?.leechersLabel.text = "\(tracker.leecherCount)"
        
        tmp?.downloadsLabel.text = "\(tracker.downloadCount)"
        
        return tmp!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
}
