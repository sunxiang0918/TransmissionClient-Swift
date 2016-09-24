//
//  AddSiteViewController.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/12/1.
//  Copyright © 2015年 SUN. All rights reserved.
//

import UIKit
import OnePasswordExtension

class AddSiteViewController : UIViewController {

    @IBOutlet weak var urlTextField: UITextField!
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var onePasswordButton: UIButton!
    
    /// 取消处理的 闭包.由外部来定义操作
    var cancelHandel:(()->Void)?
    
    /// 增加站点处理的闭包
    var addActionHandel:((SiteInfoVO)->Bool)!
    
    var onepasswordActionHandel:((UIButton)->Void)?
    
    
    override func viewWillAppear(_ animated: Bool) {
        onePasswordButton.isHidden = !OnePasswordExtension.shared().isAppExtensionAvailable()
    }
    
    @IBAction func doOnePasswordAction(_ sender: UIButton) {
        onepasswordActionHandel?(sender)
    }
    
    @IBAction func doAddSiteAction(_ sender: UIButton) {
        
        let url = urlTextField.text
        
        if let _url = url {
            if _url == "" {
                urlTextField.layer.borderWidth = 1
                urlTextField.layer.borderColor = UIColor.red.cgColor
                return
            }else{
                urlTextField.layer.borderWidth = 0
                urlTextField.layer.borderColor = UIColor.clear.cgColor
            }
            let site = SiteInfoVO(url: _url)
            site.userName = userNameTextField.text == "" ? nil : userNameTextField.text
            site.password = passwordTextField.text == "" ? nil : passwordTextField.text
            
            if addActionHandel(site) {
                urlTextField.text = nil
                userNameTextField.text = nil
                passwordTextField.text = nil
                
                cancelHandel?()
                
                //表示添加成功
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    
}
