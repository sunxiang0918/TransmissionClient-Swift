//
//  AddSitePopupView.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/25.
//  Copyright © 2015年 SUN. All rights reserved.
//

//
//  PopupView.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/24.
//  Copyright © 2015年 SUN. All rights reserved.
//

import UIKit

class AddSitePopupView:UIView {
    
    @IBOutlet weak var urlField: UITextField!
    
    @IBOutlet weak var userNameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    /// 取消处理的 闭包.由外部来定义操作
    var cancelHandel:(()->Void)?
    
    /// 增加站点处理的闭包
    var addActionHandel:((SiteInfoVO)->Bool)!
    
    @IBAction func doAddAction(sender: UIButton) {
        
        let url = urlField.text
        
        if let _url = url {
            let site = SiteInfoVO(url: _url)
            site.userName = userNameField.text == "" ? nil : userNameField.text
            site.password = passwordField.text == "" ? nil : passwordField.text
            
            if addActionHandel(site) {
                urlField.text = nil
                userNameField.text = nil
                passwordField.text = nil
                
                cancelHandel?()
            }
        }
        
    }
}

