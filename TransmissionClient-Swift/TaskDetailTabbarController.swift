//
//  TaskDetailTabbarController.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/28.
//  Copyright © 2015年 SUN. All rights reserved.
//

import UIKit

class TaskDetailTabbarController : UITabBarController,UITabBarControllerDelegate {
    
    var taskDetail:TaskDetailVO!
    
    override func viewDidLoad() {
        self.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let _viewControllers = viewControllers else {
            return
        }
        
        for viewController in _viewControllers{
            var taskDetailProtocol = viewController as! TaskDetailProtocol
            taskDetailProtocol.taskDetail = taskDetail
        }
        
    }
    
//    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
//        print(viewController)
//    }
    
}
