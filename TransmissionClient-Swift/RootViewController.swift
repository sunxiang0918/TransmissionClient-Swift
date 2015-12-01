//
//  RootViewController.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/24.
//  Copyright © 2015年 SUN. All rights reserved.
//

import UIKit
import CNPPopupController
import JCAlertView
import OnePasswordExtension

class RootViewController: UITableViewController{
    
    var siteInfos:[SiteInfoVO] = []
    
    override func viewDidLoad() {
        //界面加载前,从存储中获取已经保存了的站点信息.
        let defaultCache=NSUserDefaults.standardUserDefaults()
        let siteInfos=defaultCache.arrayModelForKey("siteInfo") as? [SiteInfoVO]
        
        if let _siteInfos = siteInfos {
            self.siteInfos = _siteInfos
        }
        
    }
    
    private func initAddSiteViewController(addSiteViewController:AddSiteViewController){
        
        /// 设置弹出视图中 取消操作的 动作闭包
//        addSiteViewController.cancelHandel = {}
        addSiteViewController.addActionHandel = {(site:SiteInfoVO)->Bool in
            self.siteInfos.append(site)
            NSUserDefaults.standardUserDefaults().setArrayModels(self.siteInfos, forKey: "siteInfo")
            self.tableView.reloadData()
            return true
        }
        
        addSiteViewController.onepasswordActionHandel = {(sender:UIButton)->Void in
            OnePasswordExtension.sharedExtension().findLoginForURLString("", forViewController: self, sender: sender) { (_loginDictionary, error) -> Void in
                guard let loginDictionary = _loginDictionary else {
                    return
                }
                if loginDictionary.count == 0 {
                    if error!.code != Int(AppExtensionErrorCodeCancelledByUser) {
                        //TODO
                    }
                    return
                }
                
                addSiteViewController.userNameTextField.text = loginDictionary[AppExtensionUsernameKey] as? String
                addSiteViewController.passwordTextField.text = loginDictionary[AppExtensionPasswordKey] as? String
                
            }
        }
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
            JCAlertView.showOneButtonWithTitle("错误", message: "无法访问\(siteInfo.url)服务器", buttonType: JCAlertViewButtonType.Default, buttonTitle: "确定",click: nil)
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            return
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
            // 设置默认的超时时间为20秒
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()//默认配置
            config.timeoutIntervalForRequest = 10 //连接超时时间
            try NSURLSession(configuration: config).sendSynchronousDataTaskWithRequest(request, returningResponse: &response)
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
        }else if segue.identifier == "addSiteSegue" {
            let addSiteViewController = segue.destinationViewController as! AddSiteViewController
            
            if addSiteViewController.onepasswordActionHandel == nil || addSiteViewController.addActionHandel == nil {
                initAddSiteViewController(addSiteViewController)
            }
        }
    }
    
    @IBAction func addSiteAction(sender: UIBarButtonItem) {
        
        self.performSegueWithIdentifier("addSiteSegue", sender: nil)
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