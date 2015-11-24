//
//  SiteInfoVO.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/24.
//  Copyright © 2015年 SUN. All rights reserved.
//

import Foundation

class SiteInfoVO : NSObject,NSCoding {
    
    let url:String
    
    var userName:String?
    
    var password:String?
    
    init(url:String){
        self.url = url
    }
    
    @objc internal func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(url, forKey: "url")
        aCoder.encodeObject(userName, forKey: "userName")
        aCoder.encodeObject(password, forKey: "password")
    }
    
    @objc internal required init?(coder aDecoder: NSCoder) {
        url = aDecoder.decodeObjectForKey("url") as! String
        
        userName = aDecoder.decodeObjectForKey("userName") as? String
        password = aDecoder.decodeObjectForKey("password") as? String
    }
    
    
}
