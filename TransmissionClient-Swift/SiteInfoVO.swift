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
    
    @objc internal func encode(with aCoder: NSCoder) {
        aCoder.encode(url, forKey: "url")
        aCoder.encode(userName, forKey: "userName")
        aCoder.encode(password, forKey: "password")
    }
    
    @objc internal required init?(coder aDecoder: NSCoder) {
        url = aDecoder.decodeObject(forKey: "url") as! String
        
        userName = aDecoder.decodeObject(forKey: "userName") as? String
        password = aDecoder.decodeObject(forKey: "password") as? String
    }
    
    
}
