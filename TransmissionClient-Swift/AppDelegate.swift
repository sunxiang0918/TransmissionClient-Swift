//
//  AppDelegate.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/23.
//  Copyright © 2015年 SUN. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    /**
     这个方法就是用来 当从其他三方的程序通过"打开其他..." 打开这个程序时调用的方法
     
     - parameter application:
     - parameter url:
     - parameter sourceApplication:
     - parameter annotation:
     
     - returns:
     */
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        let encrypteddata = NSData(contentsOfURL: url)
        
        let base64 = encrypteddata!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        //这个值就是种子文件的内容
        
        let defaultCache=NSUserDefaults.standardUserDefaults()
        defaultCache.setObject(base64, forKey: "metainfo")
        
        do {
            //尝试删除文件
            try NSFileManager.defaultManager().removeItemAtURL(url)
        } catch let e {
            print(e)
        }
        
        
        return true
    }
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

