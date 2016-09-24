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
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let encrypteddata = try? Data(contentsOf: url)
        _ = NSNotification.Name.UIApplicationDidBecomeActive
        let base64 = encrypteddata!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        //这个值就是种子文件的内容
        
        let defaultCache=UserDefaults.standard
        defaultCache.set(base64, forKey: "metainfo")
        do {
            //尝试删除文件
            try FileManager.default.removeItem(at: url)
        } catch let e {
            print(e)
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

