//
//  NewTaskController.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/26.
//  Copyright © 2015年 SUN. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON3
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        destDirTextField.text = downloadDir
        
        freeSpaceLabel.text = "剩余空间:\(SpeedStringFormatter.formatSpeedToString(freeSpace))"
        
        startWhenAddedSwitch.isSelected = true
        
        let defaultCache=UserDefaults.standard
        torrentFile = defaultCache.object(forKey: "metainfo") as? String
        
        if let _ = torrentFile{
            //如果存在拷贝的文件的话,这里就直接显示file://
            urlTextField.text = "已从其他程序拷贝torrent文件"
        }else {
            urlTextField.text = ""
        }
    }
    
    @IBAction func doAddTaskAction(_ sender: UIButton) {
        
        if urlTextField.text == nil || "" == urlTextField.text! {
            JCAlertView.showOneButton(withTitle: "错误", message: "没有填写Torrent的URL路径,无法添加", buttonType: JCAlertViewButtonType.default, buttonTitle: "确定",click: nil)
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
        let paused = !startWhenAddedSwitch.isSelected
        
        Alamofire.request(siteUrl + BASE_URL,method:.post, encoding: CustomParameterEncoding.default({()->String in
            var body = "{\"method\":\"torrent-add\",\"arguments\":{\"download-dir\":\"\(path)\",\"paused\":\(paused)"
            if  filename == "已从其他程序拷贝torrent文件" && self.torrentFile != nil {
                body = body + ",\"metainfo\":\"\(self.torrentFile!)\""
            }else {
                body = body + ",\"filename\":\"\(filename)\""
            }
            body = body + "}}"
            return body
            }()), headers: headers).responseJSON { response -> Void in
                
                switch(response.result) {
                case .success(_):
                    if  filename == "已从其他程序拷贝torrent文件" {
                        self.torrentFile = nil
                        let defaultCache=UserDefaults.standard
                        defaultCache.removeObject(forKey: "metainfo")
                    }
                    //表示添加成功
                    _ = self.navigationController?.popViewController(animated: true)
                    break
                case .failure(_):
                    //表示失败
                    JCAlertView.showOneButton(withTitle: "错误", message: "添加Torrent:\(filename) 失败", buttonType: JCAlertViewButtonType.default, buttonTitle: "确定",click: nil)
                    break
                }
        }
        
        
    }
    
    @IBAction func dirChangeAction(_ sender: UITextField) {
        
        var headers:[String:String] = [:]
        headers["X-Transmission-Session-Id"] = sessionId
        
        if let _author = author {
            headers["Authorization"] = _author
        }
        
        let path = sender.text == nil ? "/" : sender.text!
        
        Alamofire.request(siteUrl + BASE_URL,method:.post, encoding: CustomParameterEncoding.default("{\"method\":\"free-space\",\"arguments\":{\"path\":\"\(path)\"}}"), headers: headers).responseJSON { response -> Void in
            
            if case let .success(result) = response.result {
                let json = JSON(result)
                
                let size = json["arguments"]["size-bytes"].intValue
                
                self.freeSpaceLabel.text = "剩余空间:\(SpeedStringFormatter.formatSpeedToString(size))"

            }
        }
        
    }
}
