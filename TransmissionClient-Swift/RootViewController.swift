//
//  RootViewController.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/24.
//  Copyright © 2015年 SUN. All rights reserved.
//

import UIKit

class RootViewController: UITableViewController {
    
    var siteInfos:[SiteInfoVO] = []
    
    override func viewDidLoad() {
        //界面加载前,从存储中获取已经保存了的站点信息.
        let defaultCache=NSUserDefaults.standardUserDefaults()
        let siteInfos=defaultCache.arrayModelForKey("siteInfo") as? [SiteInfoVO]
        
        if let _siteInfos = siteInfos {
            self.siteInfos = _siteInfos
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
            //TODO 报错
        }
        
        self.performSegueWithIdentifier("showTaskListSegue", sender: SiteInfo(sessionId: sessionId!, url: siteInfo.url, author: author))
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
    
    //    @IBAction func doAction(sender: UIButton) {
    //
    //        var parameters:[String:AnyObject] = [:]
    //        parameters["method"] = "session-stats"
    //
    //        var headers:[String:String] = [:]
    //        headers["Authorization"] = "Basic YWRtaW46c2V2LUl6LWtFaXQtYW4tZg=="
    //        headers["X-Transmission-Session-Id"] = "Q4n3g8KN9OqcmHUNQFmLowecG3wo72wBWAXrkC76O250IaQL"
    //
    //        Alamofire.Manager.sharedInstance.request(Method.GET, "http://10.0.0.7:9091/transmission/rpc", parameters: parameters, encoding: ParameterEncoding.URL, headers: headers).responseJSON { (_, response, data) -> Void in
    //            print("status:\(response?.statusCode)")
    //
    //            if  let result = data.value {
    //                let json = JSON(result)
    //                print("data:\(json)")
    //
    //                self.result.text = json.string
    //            }
    //            
    //            
    //        }
    //    }

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