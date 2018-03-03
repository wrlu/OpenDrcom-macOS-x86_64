//
//  AppDelegate.swift
//  OpenDrcom
//
//  Created by 路伟饶 on 2017/6/30.
//  Copyright © 2017年 路伟饶. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "isLoadFromLogout")
    }
    
    /// 关闭最后一个窗口之后退出程序
    ///
    /// - Parameter sender: NSApplication实例
    /// - Returns: 是否启用此特性
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true;
    }

}

