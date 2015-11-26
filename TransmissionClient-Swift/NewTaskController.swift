//
//  NewTaskController.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/26.
//  Copyright © 2015年 SUN. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import JCAlertView

class NewTaskController : UIViewController {
    
    var siteUrl:String!
    
    var author:String?
    
    var sessionId:String!
    
    var downloadDir:String!
    
    var freeSpace:Int = 0
    
    var torrentFile:String?
    
    @IBOutlet weak var urlTextField: UITextField!
    
    @IBOutlet weak var destDirTextField: UITextField!
    
    @IBOutlet weak var freeSpaceLabel: UILabel!
    
    @IBOutlet weak var startWhenAddedSwitch: UISwitch!
    
    override func viewWillAppear(animated: Bool) {
        
        destDirTextField.text = downloadDir
        
        freeSpaceLabel.text = "剩余空间:\(SpeedStringFormatter.formatSpeedToString(freeSpace))"
        
        startWhenAddedSwitch.selected = true
        
        let defaultCache=NSUserDefaults.standardUserDefaults()
        torrentFile = defaultCache.objectForKey("metainfo") as? String
        
        if let _ = torrentFile{
            //如果存在拷贝的文件的话,这里就直接显示file://
            urlTextField.text = "已从其他程序拷贝torrent文件"
        }else {
            urlTextField.text = ""
        }
    }
    
    @IBAction func doAddTaskAction(sender: UIButton) {
        
        if urlTextField.text == nil || "" == urlTextField.text! {
            JCAlertView.showOneButtonWithTitle("错误", message: "没有填写Torrent的URL路径,无法添加", buttonType: JCAlertViewButtonType.Default, buttonTitle: "button",click: nil)
            return
        }
        
        let filename = urlTextField.text!
        
        //{"method":"torrent-add","arguments":{"download-dir":"/shares","filename":"","paused":false}}
        
        var headers:[String:String] = [:]
        headers["X-Transmission-Session-Id"] = sessionId
        
        if let _author = author {
            headers["Authorization"] = _author
        }
        
        let path = destDirTextField.text == nil ? "/" : destDirTextField.text!
        let paused = !startWhenAddedSwitch.selected
        
        Alamofire.Manager.sharedInstance.request(Method.POST, siteUrl + BASE_URL, parameters: [:], encoding: ParameterEncoding.Custom({ (convertible, params) -> (NSMutableURLRequest, NSError?) in
            /// 这个地方是用来手动的设置POST消息体的,思路就是通过ParameterEncoding.Custom闭包来设置请求的HTTPBody
            let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
            
            var body = "{\"method\":\"torrent-add\",\"arguments\":{\"download-dir\":\"\(path)\",\"paused\":\(paused)"
            if  filename == "已从其他程序拷贝torrent文件" && self.torrentFile != nil {
                body = body + ",\"metainfo\":\"\(self.torrentFile!)\""
            }else {
                body = body + ",\"filename\":\"\(filename)\""
            }
            body = body + "}}"
            
            mutableRequest.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            return (mutableRequest, nil)
        }), headers: headers).responseJSON { (_, response, data) -> Void in
            if response?.statusCode == 200 {
                if  filename == "已从其他程序拷贝torrent文件" {
                    self.torrentFile = nil
                    let defaultCache=NSUserDefaults.standardUserDefaults()
                    defaultCache.removeObjectForKey("metainfo")
                }
                //表示添加成功
                self.navigationController?.popViewControllerAnimated(true)
            }else {
                //表示失败
                JCAlertView.showOneButtonWithTitle("错误", message: "添加Torrent:\(filename) 失败", buttonType: JCAlertViewButtonType.Default, buttonTitle: "button",click: nil)
            }
        }
        
        
    }
    
    @IBAction func dirChangeAction(sender: UITextField) {
        
        var headers:[String:String] = [:]
        headers["X-Transmission-Session-Id"] = sessionId
        
        if let _author = author {
            headers["Authorization"] = _author
        }
        
        let path = sender.text == nil ? "/" : sender.text!
        
        Alamofire.Manager.sharedInstance.request(Method.POST, siteUrl + BASE_URL, parameters: [:], encoding: ParameterEncoding.Custom({ (convertible, params) -> (NSMutableURLRequest, NSError?) in
            /// 这个地方是用来手动的设置POST消息体的,思路就是通过ParameterEncoding.Custom闭包来设置请求的HTTPBody
            let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
            mutableRequest.HTTPBody = "{\"method\":\"free-space\",\"arguments\":{\"path\":\"\(path)\"}}".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            return (mutableRequest, nil)
        }), headers: headers).responseJSON { (_, response, data) -> Void in
            if response?.statusCode == 200 {
                if  let result = data.value {
                    let json = JSON(result)
                    
                    let size = json["arguments"]["size-bytes"].intValue
                    
                    self.freeSpaceLabel.text = "剩余空间:\(SpeedStringFormatter.formatSpeedToString(size))"
                }

            }
            
        }
        
    }
}
