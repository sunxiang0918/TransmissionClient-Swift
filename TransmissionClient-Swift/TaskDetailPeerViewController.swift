//
//  TaskDetailPeerViewController.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/28.
//  Copyright © 2015年 SUN. All rights reserved.
//

import UIKit

class TaskDetailPeerViewController : UITableViewController,TaskDetailProtocol {
    
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
        let nib=UINib(nibName: "TaskDetailPeerTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "taskDetailPeerTableViewCell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let _peers = _taskDetail.peers
        
        guard let peers = _peers else {
            return 0
        }
        
        return peers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var tmp = tableView.dequeueReusableCell(withIdentifier: "taskDetailPeerTableViewCell") as? TaskDetailPeerTableViewCell
        
        if (tmp == nil) {
            tmp = TaskDetailPeerTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "taskDetailPeerTableViewCell")
        }
        
        let _peer = _taskDetail.peers?[(indexPath as NSIndexPath).row]
        
        guard let peer = _peer else {
            return tmp!
        }
        
        tmp?.addressLabel.text = peer.address
        tmp?.flagLabel.text = peer.flagStr
        tmp?.processLabel.text = String(format: "%.1f", peer.progress*100)+"%"
        tmp?.clientLabel.text = peer.clientName
        tmp?.uploadLabel.text = "\(SpeedStringFormatter.formatSpeedToString(peer.rateToPeer))/S"
        tmp?.downloadLabel.text = "\(SpeedStringFormatter.formatSpeedToString(peer.rateToClient))/S"
        
        return tmp!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
