//
//  PopupView.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/24.
//  Copyright © 2015年 SUN. All rights reserved.
//

import UIKit

class StatusPopupView:UIView {
    
    let ALL = {(task:TaskVO)->Bool in return true}
    
    let ACTIVE = {(task:TaskVO)->Bool in
        return task.peersGettingFromUs > 0
    }
    
    let DOWNLOAD = {(task:TaskVO)->Bool in
        return (task.status == 3) || (task.status == 4)
    }
    
    let SEED = {(task:TaskVO)->Bool in
        return (task.status == 5) || (task.status == 6)
    }

    let PAUSED = {(task:TaskVO)->Bool in
        return task.status == 0
    }
    
    let FINISHED = {(task:TaskVO)->Bool in
        return task.isFinished
    }

    
    @IBAction func doFilteAction(_ sender: UIButton) {
        
        var oper : ((TaskVO)->Bool)? = nil
        let text = (sender.titleLabel?.text)!
        switch text {
            case "全部":
                oper = ALL
                break
            case "活动":
                oper = ACTIVE
                break
            case "下载":
                oper = DOWNLOAD
                break
            case "做种":
                oper = SEED
                break
            case "暂停":
                oper = PAUSED
                break
            case "完成":
                oper = FINISHED
                break
            default:
                oper = ALL
                break
        }
        
        doFilterStatusHandel(oper!,text)
        
        if let _c  = cancelHandel {
            _c()
        }
    }
    
    
    /// 取消处理的 闭包.由外部来定义操作
    var cancelHandel:(()->Void)?
    
    /// 点击了过滤按钮后的事件处理
    var doFilterStatusHandel:((@escaping (TaskVO)->Bool,String)->Void)!
    
}
