//
//  RootViewController.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/24.
//  Copyright © 2015年 SUN. All rights reserved.
//

import UIKit

class RootViewController: UITableViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var tmp = tableView.dequeueReusableCellWithIdentifier("rootTableViewCell")
        
        if (tmp == nil) {
            tmp = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "rootTableViewCell")
        }
        
        return tmp!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.performSegueWithIdentifier("showTaskListSegue", sender: nil)
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