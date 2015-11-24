//
//  NSUserDefaults+Model.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/24.
//  Copyright © 2015年 SUN. All rights reserved.
//

import Foundation

public extension NSUserDefaults {
    
    public func modelForKey(defaultName: String) -> AnyObject? {
        let obj = self.objectForKey(defaultName) as? NSData
        
        if let tmp = obj {
            return NSKeyedUnarchiver.unarchiveObjectWithData(tmp)
        }
        
        return nil
    }
    
    public func arrayModelForKey(defaultName: String) -> [AnyObject]? {
        let obj = self.objectForKey(defaultName) as? [NSData]
        
        var result:[AnyObject]?
        
        if let _obj = obj {
            result = []
            for tmp in _obj {
                let myModel = NSKeyedUnarchiver.unarchiveObjectWithData(tmp)
                result?.append(myModel!)
            }
            return result
        }
        return nil
    }
    
    public func setModel(value: AnyObject?, forKey defaultName: String){
        
        guard let _value = value else{
            self.setObject(nil, forKey: defaultName)
            return
        }
        
        let modelData:NSData = NSKeyedArchiver.archivedDataWithRootObject(_value)
        self.setObject(modelData, forKey: defaultName)
    }
    
    public func setArrayModels(value: [AnyObject]?, forKey defaultName: String) {
        guard let _value = value else{
            self.setObject(nil, forKey: defaultName)
            return
        }
        
        var data:[NSData] = []
        
        for v in _value {
            data.append(NSKeyedArchiver.archivedDataWithRootObject(v))
        }
        
        self.setObject(data, forKey: defaultName)
    }
}
