//
//  TaskVO.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/25.
//  Copyright © 2015年 SUN. All rights reserved.
//

import Foundation

class TaskVO {
    
    var id:Int      //任务ID
    
    var name:String     //任务名称
    
    var error:Int = 0       //任务是否失败   非0为失败
    
    var errorString:String?     //失败信息
    
    var peersConnected:Int = 0      //连接种子数
    
    var peersGettingFromUs = 0      //获取种子数
    
    var percentDone:Float = 0       //完成百分比  1就是完成
    
    var sizeWhenDon:Int = 0     //完成后的大小
    
    var totalSize:Int = 0       //本地文件大小
    
    var leftUntilDone:Int = 0       //下载剩余大小
    
    var status:Int = 0      //状态  4是下载
    
    var uploadRatio:Float = 0       //上传百分比
    
    var uploadedEver:Int = 0        //上传数据量大小
    
    var rateDownload:Int = 0        //下载速度
    
    var rateUpload:Int = 0      //上传速度
    
    init(id:Int,name:String) {
        self.id = id
        self.name = name
    }
    
}