//
//  TaskListViewController.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/24.
//  Copyright © 2015年 SUN. All rights reserved.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var tmp = tableView.dequeueReusableCellWithIdentifier("taskListTableViewCell")
        
        if (tmp == nil) {
            tmp = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "taskListTableViewCell")
        }
        
        return tmp!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.performSegueWithIdentifier("showTaskDetailSegue", sender: nil)
    }
    
    
}