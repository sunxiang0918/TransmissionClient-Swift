//
//  SpeedStringFormatter.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/25.
//  Copyright © 2015年 SUN. All rights reserved.
//

import Foundation

class SpeedStringFormatter {
    
    static let KB:Float = 1024
    static let MB = KB * 1024
    static let GB = MB * 1024
    
    static let MIN:Float = 60
    static let HOUR = MIN * 60
    static let DAY = HOUR * 24
    
    /**
     格式化速度转换成字符串,输入是字节
     
     - parameter speed:
     
     - returns:
     */
    static func formatSpeedToString(sp:Int) -> String {
        
        let speed:Float = Float(sp)
        
        if (speed >= GB) {
            return String(format: "%.2f GB", speed / GB)
        } else if (speed >= MB) {
            let fa = speed / MB;
            return String(format: fa > 100 ? "%.0f MB" : "%.2f MB", fa)
        } else if (speed >= KB) {
            let f = speed / KB;
            return String(format: f > 100 ? "%.0f KB" : "%.1f KB", f);
        } else {
            return "\(sp) B";
        }
    }
    
    /**
     根据秒数,获取时间字符串
     
     - parameter second:
     
     - returns:
     */
    static func clcaultTimesToString(second:Float) -> String {
        
        if (second >= DAY) {
            return String(format: "%.2f天", second / DAY)
        } else if (second >= HOUR) {
            let fa = second / HOUR;
            return String(format: fa > 6 ? "%.0f小时" : "%.2f小时", fa)
        } else if (second >= MIN) {
            let f = second / MIN;
            return String(format: f > 6 ? "%.0f分钟" : "%.1f分钟", f);
        } else {
            return "\(Int(second))秒";
        }
    }
    
    /**
     通过大小和速度,计算剩余时间
     
     - parameter size:
     - parameter speed:
     
     - returns:
     */
    static func clcaultHoursToString(size:Int,speed:Int) -> String {
        let s = size / (speed + 1)
        
        let second:Float = Float(s)
        
        return clcaultTimesToString(second)
        
    }
    
}