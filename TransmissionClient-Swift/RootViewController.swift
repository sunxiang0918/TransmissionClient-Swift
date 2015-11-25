//
//  RootViewController.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/24.
//  Copyright © 2015年 SUN. All rights reserved.
//

import UIKit
import CNPPopupController

class RootViewController: UITableViewController,CNPPopupControllerDelegate {
    
    var siteInfos:[SiteInfoVO] = []
    
    private var popupController : CNPPopupController?
    
    override func viewDidLoad() {
        //界面加载前,从存储中获取已经保存了的站点信息.
        let defaultCache=NSUserDefaults.standardUserDefaults()
        let siteInfos=defaultCache.arrayModelForKey("siteInfo") as? [SiteInfoVO]
        
        if let _siteInfos = siteInfos {
            self.siteInfos = _siteInfos
        }
        
        //实例化 popupController
        initPopupController()
    }
    
    private func initPopupController(){
        
        /// 实例化SharePopupView 弹出视图
        let view = UINib(nibName: "AddSitePopupView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as? AddSitePopupView
        /// 设置弹出视图的大小
        view?.frame = CGRectMake(0, 0, self.view.frame.width, 200)
        
        /// 设置弹出视图中 取消操作的 动作闭包
        view?.cancelHandel = {self.popupController?.dismissPopupControllerAnimated(true)}
        view?.addActionHandel = {(site:SiteInfoVO)->Bool in
            self.siteInfos.append(site)
            NSUserDefaults.standardUserDefaults().setArrayModels(self.siteInfos, forKey: "siteInfo")
            self.tableView.reloadData()
            return true
        }
        
        /// 实例化弹出控制器
        self.popupController = CNPPopupController(contents: [view!])
        self.popupController!.theme = CNPPopupTheme.defaultTheme()
        /// 设置点击背景取消弹出视图
        self.popupController!.theme.shouldDismissOnBackgroundTouch = true
        self.popupController!.theme.popupStyle = CNPPopupStyle.Centered
        self.popupController!.theme.presentationStyle = CNPPopupPresentationStyle.SlideInFromTop
        //设置最大宽度,否则可能会在IPAD上出现只显示一半的情况,因为默认就只有300宽
        self.popupController!.theme.maxPopupWidth = self.view.frame.width
        /// 设置视图的边框
        self.popupController!.theme.popupContentInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        self.popupController!.delegate = self;
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.siteInfos.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var tmp = tableView.dequeueReusableCellWithIdentifier("rootTableViewCell")
        
        if (tmp == nil) {
            tmp = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "rootTableViewCell")
        }
        
        tmp?.textLabel?.text = self.siteInfos[indexPath.row].url
        
        return tmp!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let siteInfo = self.siteInfos[indexPath.row]
        let author = self.generateAuthorizationString(siteInfo.userName, userPassword: siteInfo.password)
        let sessionId = getSessionID(siteInfo.url,author: author )
        
        if sessionId == nil {
            //TODO 报错
        }
        
        self.performSegueWithIdentifier("showTaskListSegue", sender: SiteInfo(sessionId: sessionId!, url: siteInfo.url, author: author))
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if  editingStyle == UITableViewCellEditingStyle.Delete {
            
            self.siteInfos.removeAtIndex(indexPath.row)
            NSUserDefaults.standardUserDefaults().setArrayModels(self.siteInfos, forKey: "siteInfo")
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    /**
     获取Session的ID
     */
    func getSessionID(var url:String,author:String?) -> String?{
        if  !url.lowercaseStringWithLocale(NSLocale.currentLocale()).hasPrefix("http://") {
            url = "http://" + url
        }
        let request = NSMutableURLRequest(URL: NSURL(string: url+BASE_URL)!)
        if let _author = author{
            request.addValue(_author, forHTTPHeaderField: "Authorization")
        }
        request.HTTPMethod = "GET"
        
        var response:NSURLResponse? = nil
        
        do {
            try NSURLSession.sharedSession().sendSynchronousDataTaskWithRequest(request, returningResponse: &response)
        } catch _ {
            return nil
        }
        
        let result = response as? NSHTTPURLResponse
        
        return result?.allHeaderFields["X-Transmission-Session-Id"] as? String
        
    }
    
    /**
     生成Base64的 认证字符串. 格式为  (userName:password) --> base64
     
     - parameter userName:
     - parameter userPassword:
     
     - returns:
     */
    private func generateAuthorizationString(userName:String?,userPassword:String?) -> String? {
        guard let _userName = userName else {
            return nil
        }
        
        let s = _userName + ":" + (userPassword==nil ? "" : userPassword!)
        
        let data = s.dataUsingEncoding(NSUTF8StringEncoding)
        
        return "Basic " + data!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTaskListSegue" {
            let taskListViewController = segue.destinationViewController as! TaskListViewController
            
            let siteInfo = sender as? SiteInfo
            
            taskListViewController.author = siteInfo?.author
            taskListViewController.sessionId = siteInfo?.sessionId
            var url : String = (siteInfo?.url)!
            
            if  !url.lowercaseStringWithLocale(NSLocale.currentLocale()).hasPrefix("http://") {
                url = "http://" + url
            }
            taskListViewController.siteUrl = url
        }
    }
    
    @IBAction func addSiteAction(sender: UIBarButtonItem) {
        self.popupController?.presentPopupControllerAnimated(true)
    }
    
}

private class SiteInfo : NSObject {
    
    let sessionId:String
    let url:String
    let author:String?
    
    init(sessionId:String,url:String,author:String?){
        self.url = url
        self.sessionId = sessionId
        self.author = author
    }
}