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
        self.tableView.registerNib(nib, forCellReuseIdentifier: "taskDetailFileTavleViewCell")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let _files = showFiles
        
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
        
        let _file = showFiles?[indexPath.row]
        
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let parentNode = (showFiles?[indexPath.row])!
        
        if  parentNode.isLeaf {
            //如果是叶子节点就直接返回了,既不能展开也不能收缩
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            return
        }
        
        //如果不是叶子节点,那么就能展开或收缩了
        let startPosition = indexPath.row+1;
        var endPosition = startPosition;
        
        var expand = false
        
        let files = (_taskDetail.files)!
        
        for (_,file) in files.enumerate() {
            if  (file.pid != nil) && (file.pid == parentNode.id) {
                file.expand = !file.expand
                
                if  file.expand {
                    showFiles?.insert(file, atIndex: endPosition)
                    expand = true
                    endPosition++
                }else {
                    expand = false
                    endPosition = removeAllNodesAtParentNode(parentNode)
                    break
                }
            }
        }
        
        //获得需要修正的indexPath
        var indexPathArray:[NSIndexPath] = []
        for var i=startPosition;i<endPosition;i++ {
            let tempIndexPath = NSIndexPath(forRow: i, inSection: 0)
            indexPathArray.append(tempIndexPath)
        }
        
//        //插入或者删除相关节点
        if (expand) {
            self.tableView.insertRowsAtIndexPaths(indexPathArray, withRowAnimation: .None)
        }else{
            self.tableView.deleteRowsAtIndexPaths(indexPathArray, withRowAnimation: .None)
        }
        
    }
    
    /**
    *  删除该父节点下的所有子节点（包括孙子节点）
    *
    *  @param parentNode 父节点
    *
    *  @return 邻接父节点的位置距离该父节点的长度，也就是该父节点下面所有的子孙节点的数量
    */
    private func removeAllNodesAtParentNode(parentNode:FileVO) -> Int{
        
        guard var showFiles = self.showFiles else {
            return 0
        }
        
        let startPosition = (showFiles.indexOf(parentNode))!
        var endPosition = startPosition
        
        for file in showFiles[startPosition+1..<showFiles.count] {
            endPosition++
            if  file.layer <= parentNode.layer {
                break
            }
            
            if  endPosition == showFiles.count-1 {
                endPosition++
                file.expand = false
                break
            }
            
            file.expand = false
        }
        
        if (endPosition>startPosition) {
            self.showFiles?.removeRange(startPosition+1 ..< endPosition)
        }
        return endPosition
        
    }
    
}
