//
//  TaskDetailInfoViewController.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/28.
//  Copyright © 2015年 SUN. All rights reserved.
//

import UIKit

class TaskDetailInfoViewController : UIViewController,TaskDetailProtocol {
    
    fileprivate var _taskDetail:TaskDetailVO!
    
    var taskDetail:TaskDetailVO {
        get{
            return _taskDetail
        }
        set(newValue){
            _taskDetail = newValue
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var idLabel: UILabel!
    
    @IBOutlet weak var avaliabilityLabel: UILabel!
    
    @IBOutlet weak var haveLabel: UILabel!
    
    @IBOutlet weak var downloadedLabel: UILabel!
    
    @IBOutlet weak var uploadedLabel: UILabel!
    
    @IBOutlet weak var stateLabel: UILabel!
    
    @IBOutlet weak var runTimeLabel: UILabel!
    
    @IBOutlet weak var remainingTimeLabel: UILabel!
    
    @IBOutlet weak var lastActivityLabel: UILabel!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var sizeLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var hashTextView: UITextView!
    
    @IBOutlet weak var privacyLabel: UILabel!
    
    @IBOutlet weak var originLabel: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel!
    
    
    override func viewWillAppear(_ animated: Bool) {
        nameLabel.text = _taskDetail.name
        idLabel.text = "\(_taskDetail.id)"
        var avaliability = Float(_taskDetail.downloadedEver) / Float(_taskDetail.size) * 100
        if  avaliability > 100 {
            avaliability = 100
        }
        let download = SpeedStringFormatter.formatSpeedToString(_taskDetail.downloadedEver)
        let totalSize = SpeedStringFormatter.formatSpeedToString(_taskDetail.size)
        let now = Date()
        
        avaliabilityLabel.text = "\(avaliability)%"
        if _taskDetail.downloadedEver < _taskDetail.size {
            haveLabel.text = "已下载\(download)中的\(totalSize) (\(avaliability)%)"
        }else {
            haveLabel.text = "\(totalSize)(100%)"
        }
        
        downloadedLabel.text = download
        uploadedLabel.text = "\(SpeedStringFormatter.formatSpeedToString(_taskDetail.updatedEver))"
        stateLabel.text = _taskDetail.state
        
        if _taskDetail._state == 0 {
            runTimeLabel.text = _taskDetail.state
            remainingTimeLabel.text = "未知"
        }else if _taskDetail._state == 4 || _taskDetail._state == 5 {
            runTimeLabel.text = SpeedStringFormatter.clcaultTimesToString(Float(now.timeIntervalSince(_taskDetail.startDate)))
            remainingTimeLabel.text = SpeedStringFormatter.clcaultHoursToString((_taskDetail.size-_taskDetail.downloadedEver), speed: _taskDetail.downloadSpeed)
        }else {
            runTimeLabel.text = SpeedStringFormatter.clcaultTimesToString(Float(now.timeIntervalSince(_taskDetail.startDate)))
            remainingTimeLabel.text = "已完成"
        }
        
        lastActivityLabel.text = SpeedStringFormatter.clcaultTimesToString(Float(now.timeIntervalSince(_taskDetail.activityDate)))
        
        if let _error = _taskDetail.error {
            errorLabel.text = _error
        }else {
            errorLabel.text = ""
        }
        
        //(700 pieces @ 4.00 MiB)
        sizeLabel.text = "\(totalSize) (由\(_taskDetail.pieceCount)片,每片\(SpeedStringFormatter.formatSpeedToString(_taskDetail.pieceSize))组成)"
        locationLabel.text = _taskDetail.downloadDir
        if let hash = _taskDetail.hashString {
            hashTextView.text = hash
        }else {
            hashTextView.text = ""
        }
        
        privacyLabel.text = "\(_taskDetail.isPrivate ? "Private" : "Public") to this tracker"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        originLabel.text = "于\(formatter.string(from: _taskDetail.dateCreated as Date)) 由\(_taskDetail.creator)创建"
        
        if let comment = _taskDetail.comment {
            commentLabel.text = comment
        }else {
            commentLabel.text = ""
        }
    }
    
    
    
    
}
