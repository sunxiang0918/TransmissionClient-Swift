//
//  NSUserDefaults+Model.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/24.
//  Copyright © 2015年 SUN. All rights reserved.
//

import Foundation

public extension UserDefaults {
    
    public func modelForKey(_ defaultName: String) -> AnyObject? {
        let obj = self.object(forKey: defaultName) as? Data
        
        if let tmp = obj {
            return NSKeyedUnarchiver.unarchiveObject(with: tmp) as AnyObject?
        }
        
        return nil
    }
    
    public func arrayModelForKey(_ defaultName: String) -> [AnyObject]? {
        let obj = self.object(forKey: defaultName) as? [Data]
        
        var result:[AnyObject]?
        
        if let _obj = obj {
            result = []
            for tmp in _obj {
                let myModel = NSKeyedUnarchiver.unarchiveObject(with: tmp)
                result?.append(myModel! as AnyObject)
            }
            return result
        }
        return nil
    }
    
    public func setModel(_ value: AnyObject?, forKey defaultName: String){
        
        guard let _value = value else{
            self.set(nil, forKey: defaultName)
            return
        }
        
        let modelData:Data = NSKeyedArchiver.archivedData(withRootObject: _value)
        self.set(modelData, forKey: defaultName)
    }
    
    public func setArrayModels(_ value: [AnyObject]?, forKey defaultName: String) {
        guard let _value = value else{
            self.set(nil, forKey: defaultName)
            return
        }
        
        var data:[Data] = []
        
        for v in _value {
            data.append(NSKeyedArchiver.archivedData(withRootObject: v))
        }
        
        self.set(data, forKey: defaultName)
    }
}
