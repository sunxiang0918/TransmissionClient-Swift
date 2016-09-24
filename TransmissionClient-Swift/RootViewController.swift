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
        let defaultCache=UserDefaults.standard
        let siteInfos=defaultCache.arrayModelForKey("siteInfo") as? [SiteInfoVO]
        
        if let _siteInfos = siteInfos {
            self.siteInfos = _siteInfos
        }
        
    }
    
    fileprivate func initAddSiteViewController(_ addSiteViewController:AddSiteViewController){
        
        /// 设置弹出视图中 取消操作的 动作闭包
//        addSiteViewController.cancelHandel = {}
        addSiteViewController.addActionHandel = {(site:SiteInfoVO)->Bool in
            self.siteInfos.append(site)
            UserDefaults.standard.setArrayModels(self.siteInfos, forKey: "siteInfo")
            self.tableView.reloadData()
            return true
        }
        
        addSiteViewController.onepasswordActionHandel = {(sender:UIButton)->Void in
            OnePasswordExtension.shared().findLogin(forURLString: "", for: self, sender: sender) { (_loginDictionary, error) -> Void in
                guard let loginDictionary = _loginDictionary else {
                    return
                }
                if loginDictionary.count == 0 {
                    if error!._code != Int(AppExtensionErrorCodeCancelledByUser) {
                        //TODO
                    }
                    return
                }
                
                addSiteViewController.userNameTextField.text = loginDictionary[AppExtensionUsernameKey] as? String
                addSiteViewController.passwordTextField.text = loginDictionary[AppExtensionPasswordKey] as? String
                
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.siteInfos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var tmp = tableView.dequeueReusableCell(withIdentifier: "rootTableViewCell")
        
        if (tmp == nil) {
            tmp = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "rootTableViewCell")
        }
        
        tmp?.textLabel?.text = self.siteInfos[(indexPath as NSIndexPath).row].url
        
        return tmp!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let siteInfo = self.siteInfos[(indexPath as NSIndexPath).row]
        let author = self.generateAuthorizationString(siteInfo.userName, userPassword: siteInfo.password)
        let sessionId = getSessionID(siteInfo.url,author: author )
        
        if sessionId == nil {
            JCAlertView.showOneButton(withTitle: "错误", message: "无法访问\(siteInfo.url)服务器", buttonType: JCAlertViewButtonType.default, buttonTitle: "确定",click: nil)
            self.tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        self.performSegue(withIdentifier: "showTaskListSegue", sender: SiteInfo(sessionId: sessionId!, url: siteInfo.url, author: author))
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if  editingStyle == UITableViewCellEditingStyle.delete {
            
            self.siteInfos.remove(at: (indexPath as NSIndexPath).row)
            UserDefaults.standard.setArrayModels(self.siteInfos, forKey: "siteInfo")
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    /**
     获取Session的ID
     */
    func getSessionID(_ url:String,author:String?) -> String?{
        var u = url
        if  !u.lowercased(with: Locale.current).hasPrefix("http://") {
            u = "http://" + u
        }
        let request = NSMutableURLRequest(url: URL(string: u+BASE_URL)!)
        if let _author = author{
            request.addValue(_author, forHTTPHeaderField: "Authorization")
        }
        request.httpMethod = "GET"
        
        var response:URLResponse? = nil
        
        do {
            // 设置默认的超时时间为20秒
            let config = URLSessionConfiguration.default//默认配置
            config.timeoutIntervalForRequest = 10 //连接超时时间
            _ = try URLSession(configuration: config).sendSynchronousDataTaskWithRequest(request as URLRequest, returningResponse: &response)
        } catch _ {
            return nil
        }
        
        let result = response as? HTTPURLResponse
        
        return result?.allHeaderFields["X-Transmission-Session-Id"] as? String
        
    }
    
    /**
     生成Base64的 认证字符串. 格式为  (userName:password) --> base64
     
     - parameter userName:
     - parameter userPassword:
     
     - returns:
     */
    fileprivate func generateAuthorizationString(_ userName:String?,userPassword:String?) -> String? {
        guard let _userName = userName else {
            return nil
        }
        
        let s = _userName + ":" + (userPassword==nil ? "" : userPassword!)
        
        let data = s.data(using: String.Encoding.utf8)
        
        return "Basic " + data!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTaskListSegue" {
            let taskListViewController = segue.destination as! TaskListViewController
            
            let siteInfo = sender as? SiteInfo
            
            taskListViewController.author = siteInfo?.author
            taskListViewController.sessionId = siteInfo?.sessionId
            var url : String = (siteInfo?.url)!
            
            if  !url.lowercased(with: Locale.current).hasPrefix("http://") {
                url = "http://" + url
            }
            taskListViewController.siteUrl = url
        }else if segue.identifier == "addSiteSegue" {
            let addSiteViewController = segue.destination as! AddSiteViewController
            
            if addSiteViewController.onepasswordActionHandel == nil || addSiteViewController.addActionHandel == nil {
                initAddSiteViewController(addSiteViewController)
            }
        }
    }
    
    @IBAction func addSiteAction(_ sender: UIBarButtonItem) {
        
        self.performSegue(withIdentifier: "addSiteSegue", sender: nil)
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
