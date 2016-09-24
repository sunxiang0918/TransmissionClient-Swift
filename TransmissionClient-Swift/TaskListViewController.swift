//
//  TaskListViewController.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/24.
//  Copyright © 2015年 SUN. All rights reserved.
//

import UIKit
import CNPPopupController
import Alamofire
import SwiftyJSON3
import JCAlertView

class TaskListViewController: UITableViewController,CNPPopupControllerDelegate,UISearchBarDelegate {
    
    // MARK: - 成员变量
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var siteUrl:String!
    
    var author:String?
    
    var sessionId:String!
    
    @IBOutlet weak var infoToolbarItem: UIBarButtonItem!        //底部的站点sessionInfo信息
    
    fileprivate var popupController : CNPPopupController?
    
    fileprivate var tasks : [TaskVO] = []
    
    fileprivate var filtered : [TaskVO] = []
    
    fileprivate var searchActive : Bool = false
    
    fileprivate var statusFilter : ((TaskVO)->Bool)?
    
    @IBOutlet weak var statusButton: UIBarButtonItem!
    
    // MARK: - View初始化
    
    override func viewDidLoad() {
        
        let nib=UINib(nibName: "TaskListTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "taskListTableViewCell")
        
        searchBar.delegate = self
        
        //实例化 popupController
        initPopupController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationItem.title = siteUrl
        self.navigationController?.setToolbarHidden(false, animated: true)
        
        loadSessionInfo()
        loadTaskList()
    }
    
    fileprivate func initPopupController(){
        
        /// 实例化SharePopupView 弹出视图
        let view = UINib(nibName: "StatusPopupView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? StatusPopupView
        /// 设置弹出视图的大小
        view?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)
        
        /// 设置弹出视图中 取消操作的 动作闭包
        view?.cancelHandel = {self.popupController?.dismiss(animated: true)}
        
        view?.doFilterStatusHandel = {(oper:@escaping (TaskVO)->Bool,title:String) ->Void in
            //界面点了过滤后的处理
            
            //首先把界面的字给改了
            self.statusButton.title = title
            
            //然后开始过滤
            if  title == "全部" {
                self.statusFilter = nil
            }else {
                self.statusFilter = oper
                self.filtered = self.tasks.filter { (taskVO) -> Bool in
                    return oper(taskVO)
                }
            }
            
            self.loadSessionInfo()
            self.tableView.reloadData()
        }
        
        /// 实例化弹出控制器
        self.popupController = CNPPopupController(contents: [view!])
        self.popupController!.theme = CNPPopupTheme.default()
        /// 设置点击背景取消弹出视图
        self.popupController!.theme.shouldDismissOnBackgroundTouch = true
        self.popupController!.theme.popupStyle = CNPPopupStyle.actionSheet
        self.popupController!.theme.presentationStyle = CNPPopupPresentationStyle.slideInFromTop
        //设置最大宽度,否则可能会在IPAD上出现只显示一半的情况,因为默认就只有300宽
        self.popupController!.theme.maxPopupWidth = self.view.frame.width
        /// 设置视图的边框
        self.popupController!.theme.popupContentInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        self.popupController!.delegate = self;
        
    }
    
    // MARK: - UITableView的实现
    
    //========================UITableViewDelegate的实现================================================
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive || statusFilter != nil) {
            return filtered.count
        }
        return tasks.count
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var tmp = tableView.dequeueReusableCell(withIdentifier: "taskListTableViewCell") as? TaskListTableViewCell
        
        if (tmp == nil) {
            tmp = TaskListTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "taskListTableViewCell")
        }
        
        let task = (searchActive || statusFilter != nil)  ? filtered[(indexPath as NSIndexPath).row] : tasks[(indexPath as NSIndexPath).row]
        
        tmp?.nameLabel.text = task.name
        
        var desc:String
        var status:String
        
        if task.error > 0 {
            desc = task.errorString!
            status = "文件大小\(SpeedStringFormatter.formatSpeedToString(task.totalSize)),已上传\(SpeedStringFormatter.formatSpeedToString(task.uploadedEver)) (比率 \(task.uploadRatio))"
            tmp?.descLabel.textColor = UIColor.red
            tmp?.progressView.progressTintColor = UIColor.gray
        }else {
            tmp?.descLabel.textColor = UIColor.gray
            switch task.status {
            case 0 :
                //暂停
                tmp?.progressView.progressTintColor = UIColor.gray
                desc = "已暂停"
                status = "已暂停"
            case 3,4 :
                //下载
                tmp?.progressView.progressTintColor = UIColor.blue
                desc = "从\(task.peersConnected)个peers进行下载 - ↓\(SpeedStringFormatter.formatSpeedToString(task.rateDownload))/s ↑\(SpeedStringFormatter.formatSpeedToString(task.rateUpload))/s"
                status = "已下载\(SpeedStringFormatter.formatSpeedToString(task.totalSize-task.leftUntilDone)),总共大小\(SpeedStringFormatter.formatSpeedToString(task.totalSize))(\(task.percentDone*100)%) - 预计剩余\(SpeedStringFormatter.clcaultHoursToString(task.leftUntilDone, speed: task.rateDownload))"
            default :
                tmp?.progressView.progressTintColor = UIColor(red: 0.173, green: 0.698, blue: 0.212, alpha: 1.000)
                desc = "为\(task.peersConnected)个Peers做种中 - ↑\(SpeedStringFormatter.formatSpeedToString(task.rateUpload))/s"
                status = "文件大小\(SpeedStringFormatter.formatSpeedToString(task.totalSize)),已上传\(SpeedStringFormatter.formatSpeedToString(task.uploadedEver)) (比率 \(task.uploadRatio))"
            }
        }
        
        tmp?.descLabel.text = desc
        tmp?.progressView.progress = task.percentDone
        tmp?.statusLabel.text = status
        
        return tmp!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = (self.searchActive || self.statusFilter != nil) ? self.filtered[(indexPath as NSIndexPath).row] : self.tasks[(indexPath as NSIndexPath).row]
        
        loadTaskDetailAndPerformSegue(task)
    }
    
    /**
     定义一行左滑动的事件, 这里增加了两个按钮,一个是暂停,一个是删除
     
     - parameter tableView:
     - parameter indexPath:
     
     - returns:
     */
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let task = (self.searchActive || self.statusFilter != nil) ? self.filtered[(indexPath as NSIndexPath).row] : self.tasks[(indexPath as NSIndexPath).row]
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "删除") { (action, indexPath) -> Void in
            //一行的删除操作,先调用HTTP 删除任务,如果删除成功.那么就再删除界面
            self.removeTaskFromView(task, indexPath: indexPath)
        }
        
        var action:UITableViewRowAction
        if task.status == 0 || task.error > 0 {
            //已经暂停了,那就是启动
            action = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "恢复") { (action, indexPath) -> Void in
                self.startTaskFromView(task, indexPath: indexPath)
            }
        }else{
            //其他状态就是暂停
            action = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "暂停") { (action, indexPath) -> Void in
                self.pauseTaskFromView(task, indexPath: indexPath)
            }
        }
        
        return [deleteAction,action]
    }
    
    //========================UITableViewDelegate的实现================================================
    
    // MARK: - 私有方法实现
    //=======================私有方法的实现=======================================================
    fileprivate func pauseTaskFromView(_ task:TaskVO,indexPath:IndexPath) {
        var headers:[String:String] = [:]
        headers["X-Transmission-Session-Id"] = sessionId
        
        if let _author = author {
            headers["Authorization"] = _author
        }
        
        Alamofire.request(siteUrl + BASE_URL, method: .post, encoding: CustomParameterEncoding.default("{\"arguments\": {\"ids\": [ \(task.id) ]},\"method\": \"torrent-stop\"}"), headers: headers).responseJSON { response -> Void in
            
            switch response.result {
            case .success(_):
                //表示暂停成功
                self.loadSessionInfo()
                
                //由于服务器是异步的,所以这里要适当的Sleep一下,否则任务状态还没有更新
                Thread.sleep(forTimeInterval: 0.5)
                self.loadTaskList()
            case .failure(_):
                //暂停失败
                JCAlertView.showOneButton(withTitle: "错误", message: "暂停任务\(task.name) 失败", buttonType: JCAlertViewButtonType.default, buttonTitle: "确定", click: nil)
            }
        }
    }
    
    fileprivate func startTaskFromView(_ task:TaskVO,indexPath:IndexPath) {
        var headers:[String:String] = [:]
        headers["X-Transmission-Session-Id"] = sessionId
        
        if let _author = author {
            headers["Authorization"] = _author
        }
        
        Alamofire.request(siteUrl + BASE_URL, method: .post, encoding:CustomParameterEncoding.default("{\"arguments\": {\"ids\": [ \(task.id) ]},\"method\": \"torrent-start\"}"), headers: headers).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                //表示暂停成功
                self.loadSessionInfo()
                self.loadTaskList()
                break
            case .failure(_):
                //暂停失败
                JCAlertView.showOneButton(withTitle: "错误", message: "启动任务\(task.name) 失败", buttonType: JCAlertViewButtonType.default, buttonTitle: "确定", click: nil)
                break
            }
        }
    }
    
    
    fileprivate func removeTaskFromView(_ task:TaskVO,indexPath:IndexPath) {
        var headers:[String:String] = [:]
        headers["X-Transmission-Session-Id"] = sessionId
        
        if let _author = author {
            headers["Authorization"] = _author
        }
        
        
        Alamofire.request(siteUrl + BASE_URL, method: .post, encoding:CustomParameterEncoding.default("{\"arguments\": {\"ids\": [ \(task.id) ],\"delete-local-data\":true},\"method\": \"torrent-remove\"}"), headers: headers).responseJSON { response -> Void in
            
            switch(response.result) {
            case .success(_):
                //表示删除成功
                //一行的删除操作,先调用HTTP 删除任务,如果删除成功.那么就再删除界面
                if (self.searchActive || self.statusFilter != nil) {
                    self.filtered.remove(at: indexPath.row)
                    let index = self.tasks.index(where: { (t:TaskVO) -> Bool in
                        return t.id == task.id
                    })
                    if index != nil {
                        self.tasks.remove(at: index!)
                    }
                }else{
                    self.tasks.remove(at: indexPath.row)
                }
                self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                //重新加载一次sessionInfo
                self.loadSessionInfo()
                break
            case .failure(_):
                //删除失败
                JCAlertView.showOneButton(withTitle: "错误", message: "删除任务\(task.name) 失败", buttonType: JCAlertViewButtonType.default, buttonTitle: "确定", click: nil)
                break
            }
        }
    }
    
    /**
     加载会话的总体状态
     */
    fileprivate func loadSessionInfo(){
        var headers:[String:String] = [:]
        headers["X-Transmission-Session-Id"] = sessionId
        
        if let _author = author {
            headers["Authorization"] = _author
        }
        
        var parameter:[String:String] = [:]
        parameter["method"] = "session-stats"
        
        Alamofire.request(siteUrl + BASE_URL,parameters:parameter,headers: headers).responseJSON { response -> Void in
            
            switch response.result {
            case .success(let result):
                let json = JSON(result)
            
                var torrentCount = json["arguments"]["torrentCount"].intValue
                let downloadSpeed = json["arguments"]["downloadSpeed"].intValue
                let uploadSpeed = json["arguments"]["uploadSpeed"].intValue
                
                if self.statusFilter != nil {
                    //表示有状态过滤
                    torrentCount = self.filtered.count
                }
                
                self.infoToolbarItem.title = "一共\(torrentCount)个任务 - ↓\(SpeedStringFormatter.formatSpeedToString(downloadSpeed))/s  ↑\(SpeedStringFormatter.formatSpeedToString(uploadSpeed))/s"
                
                self.infoToolbarItem.setTitleTextAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 12),NSForegroundColorAttributeName:UIColor.black], for: UIControlState.normal)
                 break
            case .failure(let error) :
                print("\(error.localizedDescription)")
                break
            }
        }
    }
    
    /**
     加载任务列表
     */
    fileprivate func loadTaskList(){
        var headers:[String:String] = [:]
        headers["X-Transmission-Session-Id"] = sessionId
        
        if let _author = author {
            headers["Authorization"] = _author
        }
        
        Alamofire.request(siteUrl + BASE_URL, method: .post, encoding: CustomParameterEncoding.default("{\"method\":\"torrent-get\",\"arguments\":{\"fields\":[\"id\",\"name\",\"error\",\"errorString\",\"isFinished\",\"peersConnected\",\"peersGettingFromUs\",\"percentDone\",\"sizeWhenDone\",\"totalSize\",\"status\",\"uploadRatio\",\"uploadedEver\",\"rateDownload\",\"rateUpload\",\"leftUntilDone\"]}}"), headers: headers).responseJSON { response -> Void in
            
            switch(response.result) {
            case .success(let result):
                self.tasks.removeAll()
                
                let json = JSON(result)
                let torrents = json["arguments"]["torrents"].array
                    
                for torrent in torrents! {
                    self.tasks.append(self.convertJson2TaskVO(torrent))
                }
                
                if self.statusFilter != nil {
                    self.filtered = self.tasks.filter { (taskVO) -> Bool in
                        return self.statusFilter!(taskVO)
                    }
                }
                
                self.tableView.reloadData()
                break
            case .failure(_):
                break
            }
        }
    }
    
    fileprivate func loadTaskDetailAndPerformSegue(_ taskVO:TaskVO) {
        
        var headers:[String:String] = [:]
        headers["X-Transmission-Session-Id"] = sessionId
        
        if let _author = author {
            headers["Authorization"] = _author
        }
        
        Alamofire.request(siteUrl + BASE_URL,method: .post, encoding: CustomParameterEncoding.default("{\"method\":\"torrent-get\",\"arguments\":{\"fields\":[\"id\",\"activityDate\",\"corruptEver\",\"desiredAvailable\",\"downloadedEver\",\"fileStats\",\"haveUnchecked\",\"haveValid\",\"peers\",\"startDate\",\"trackerStats\",\"comment\",\"creator\",\"dateCreated\",\"files\",\"hashString\",\"isPrivate\",\"pieceCount\",\"pieceSize\",\"downloadDir\",\"name\",\"rateDownload\",\"uploadedEver\"],\"ids\":[\(taskVO.id)]}}"), headers: headers).responseJSON { response -> Void in
            switch(response.result) {
            case .success(let result):
                let json = JSON(result)
                let taskDetail = TaskDetailVO(json: json,size:taskVO.totalSize,state: taskVO.status, error: taskVO.errorString)
                self.performSegue(withIdentifier: "showTaskDetailSegue", sender: taskDetail)
                break
            case .failure(_):
                //TODO 抛出异常
                break
            }
        }
        
    }
    
    /**
     把JSON对象转换成为TaskVO
     
     - parameter json:
     
     - returns:
     */
    fileprivate func convertJson2TaskVO(_ json:JSON) -> TaskVO {
        let id = json["id"].intValue
        let name = json["name"].stringValue
        
        let task = TaskVO(id: id, name: name)
        
        task.error = json["error"].intValue
        task.errorString = json["errorString"].stringValue
        task.peersConnected = json["peersConnected"].intValue
        task.peersGettingFromUs = json["peersGettingFromUs"].intValue
        task.percentDone = json["percentDone"].floatValue
        task.sizeWhenDon = json["sizeWhenDon"].intValue
        task.totalSize = json["totalSize"].intValue
        task.status = json["status"].intValue
        task.uploadRatio = json["uploadRatio"].floatValue
        task.uploadedEver = json["uploadedEver"].intValue
        task.rateDownload = json["rateDownload"].intValue
        task.rateUpload = json["rateUpload"].intValue
        task.leftUntilDone = json["leftUntilDone"].intValue
        task.isFinished = json["isFinished"].boolValue
        return task
    }
    
    //=======================私有方法的实现=======================================================
    
    // MARK: - 界面Button事件
    //========================UIButtonAction的实现================================================
    @IBAction func doStatusAction(_ sender: UIBarButtonItem) {
        self.popupController?.present(animated: true)
    }
    
    @IBAction func doRefreshAction(_ sender: UIBarButtonItem) {
        
        loadSessionInfo()
        loadTaskList()
    }
    
    @IBAction func doAddAction(_ sender: UIBarButtonItem) {
        
        //这个地方的逻辑是查询一次当前磁盘的剩余,以及默认目标路径
        var headers:[String:String] = [:]
        headers["X-Transmission-Session-Id"] = sessionId
        
        if let _author = author {
            headers["Authorization"] = _author
        }
        
        var parameter:[String:String] = [:]
        parameter["method"] = "session-get"
        
        Alamofire.request(siteUrl + BASE_URL,parameters:parameter,headers: headers).responseJSON { response -> Void in
            
            switch response.result {
            case .success(let result) :
                let json = JSON(result)
                
                let downloadDir = json["arguments"]["download-dir"].stringValue
                let freeSpace = json["arguments"]["download-dir-free-space"].intValue
                
                self.performSegue(withIdentifier: "addTaskSegue", sender: DefaultDownloadInfo(downloadDir: downloadDir, freeSpace: freeSpace))
                break
            case .failure(_):break
            }
        }
    }
    
    //========================UIButtonAction的实现================================================
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTaskSegue" {
            let newTaskController = segue.destination as! NewTaskController
            let downloadInfo = sender as! DefaultDownloadInfo
            
            newTaskController.siteUrl = siteUrl
            newTaskController.author = author
            newTaskController.sessionId = sessionId
            newTaskController.downloadDir = downloadInfo.downloadDir
            newTaskController.freeSpace = downloadInfo.freeSpace
        }else if segue.identifier == "showTaskDetailSegue" {
            let taskDetailTabbarController = segue.destination as! TaskDetailTabbarController
            
            let taskDetail = sender as! TaskDetailVO
            taskDetailTabbarController.taskDetail = taskDetail
        }

    }
    
    // MARK: - CNPPopupControllerDelegate实现
    //========================CNPPopupControllerDelegate的实现================================================
    
    //========================CNPPopupControllerDelegate的实现================================================
    
    // MARK: - UISearchBarDelegate实现
    //========================UISearchBarDelegate的实现================================================
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        self.tableView.reloadData()
    }
    
//    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
//        searchActive = false;
//    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if  "" == searchText {
            searchActive = false
            self.tableView.reloadData()
            return
        }
        
        filtered = tasks.filter { (taskVO) -> Bool in
            let tmp = taskVO.name
            return tmp.contains(searchText)
        }
        
//        if(filtered.count == 0){
//            searchActive = false
//        } else {
//            searchActive = true
//        }
        searchActive = true
        self.tableView.reloadData()
    }
    //========================UISearchBarDelegate的实现================================================
}

private class DefaultDownloadInfo : NSObject {
    var downloadDir:String
    var freeSpace:Int
    
    init(downloadDir:String,freeSpace:Int = 0){
        self.downloadDir = downloadDir
        self.freeSpace = freeSpace
    }
}
