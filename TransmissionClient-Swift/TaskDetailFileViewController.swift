//
//  TaskDetailFileViewController.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/28.
//  Copyright © 2015年 SUN. All rights reserved.
//

import UIKit

class TaskDetailFileViewController : UITableViewController,TaskDetailProtocol {
    
    fileprivate var _taskDetail:TaskDetailVO!
    
    var taskDetail:TaskDetailVO {
        get{
            return _taskDetail
        }
        set(newValue){
            _taskDetail = newValue
            let _files = newValue.files
            
            if let files = _files {
                showFiles = []
                for file in files {
                    if file.expand {
                        showFiles?.append(file)
                    }
                }
            }
        }
    }
    
    var showFiles:[FileVO]?    //显示的部分数据
    
    override func viewDidLoad() {
        let nib=UINib(nibName: "TaskDetailFileTavleViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "taskDetailFileTavleViewCell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let _files = showFiles
        
        guard let files = _files else {
            return 0
        }
        
        return files.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var tmp = tableView.dequeueReusableCell(withIdentifier: "taskDetailFileTavleViewCell") as? TaskDetailFileTavleViewCell
        
        if (tmp == nil) {
            tmp = TaskDetailFileTavleViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "taskDetailFileTavleViewCell")
        }
        
        let _file = showFiles?[(indexPath as NSIndexPath).row]
        
        guard let file = _file else {
            return tmp!
        }
        
        tmp?.leadingDocument.constant = CGFloat((file.layer-1) * -20)
        
        if file.isLeaf {
            tmp?.images?.image = UIImage(named: "Document-01-128-2")
        }else {
            tmp?.images?.image = UIImage(named: "Folder-New-01-128-2")
        }
        
        tmp?.fileNameLabel.text = file.name
        
        //1.20 GB of 1.20 GB (100%)
        tmp?.statusLabel.text = "\(SpeedStringFormatter.formatSpeedToString(file.bytesCompleted)) of \(SpeedStringFormatter.formatSpeedToString(file.length)) (\(Float(file.bytesCompleted)/Float(file.length) * 100)%)"
        
        if !file.wanted {
            tmp?.backgroundColor = UIColor.lightGray
        }else {
            tmp?.backgroundColor = UIColor.clear
        }
        
        switch file.priority {
        case -1:
            tmp?.upButton.isSelected = false
            tmp?.norButton.isSelected = false
            tmp?.downButton.isSelected = true
            break
        case 0:
            tmp?.upButton.isSelected = false
            tmp?.norButton.isSelected = true
            tmp?.downButton.isSelected = false
            break
        case 1:
            tmp?.upButton.isSelected = true
            tmp?.norButton.isSelected = false
            tmp?.downButton.isSelected = false
            break
        default:
            tmp?.upButton.isSelected = false
            tmp?.norButton.isSelected = true
            tmp?.downButton.isSelected = false
            break
        }
        
        return tmp!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let parentNode = (showFiles?[(indexPath as NSIndexPath).row])!
        
        if  parentNode.isLeaf {
            //如果是叶子节点就直接返回了,既不能展开也不能收缩
            self.tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        //如果不是叶子节点,那么就能展开或收缩了
        let startPosition = (indexPath as NSIndexPath).row+1;
        var endPosition = startPosition;
        
        var expand = false
        
        let files = (_taskDetail.files)!
        
        for (_,file) in files.enumerated() {
            if  (file.pid != nil) && (file.pid == parentNode.id) {
                file.expand = !file.expand
                
                if  file.expand {
                    showFiles?.insert(file, at: endPosition)
                    expand = true
                    endPosition += 1
                }else {
                    expand = false
                    endPosition = removeAllNodesAtParentNode(parentNode)
                    break
                }
            }
        }
        
        //获得需要修正的indexPath
        var indexPathArray:[IndexPath] = []
        for i in startPosition ..< endPosition {
            let tempIndexPath = IndexPath(row: i, section: 0)
            indexPathArray.append(tempIndexPath)
        }
        
//        //插入或者删除相关节点
        if (expand) {
            self.tableView.insertRows(at: indexPathArray, with: .none)
        }else{
            self.tableView.deleteRows(at: indexPathArray, with: .none)
        }
        
    }
    
    /**
    *  删除该父节点下的所有子节点（包括孙子节点）
    *
    *  @param parentNode 父节点
    *
    *  @return 邻接父节点的位置距离该父节点的长度，也就是该父节点下面所有的子孙节点的数量
    */
    fileprivate func removeAllNodesAtParentNode(_ parentNode:FileVO) -> Int{
        
        guard var showFiles = self.showFiles else {
            return 0
        }
        
        let startPosition = (showFiles.index(of: parentNode))!
        var endPosition = startPosition
        
        for file in showFiles[startPosition+1..<showFiles.count] {
            endPosition += 1
            if  file.layer <= parentNode.layer {
                break
            }
            
            if  endPosition == showFiles.count-1 {
                endPosition += 1
                file.expand = false
                break
            }
            
            file.expand = false
        }
        
        if (endPosition>startPosition) {
            self.showFiles?.removeSubrange(startPosition+1 ..< endPosition)
        }
        return endPosition
        
    }
    
}
