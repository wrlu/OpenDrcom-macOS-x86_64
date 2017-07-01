//
//  SuccessInfoViewController.swift
//  OpenDrcom
//
//  Created by 路伟饶 on 2017/6/30.
//  Copyright © 2017年 路伟饶. All rights reserved.
//

import Cocoa

class SuccessInfoViewController: NSViewController {
    @IBOutlet weak var labelUserIP: NSTextField!
    @IBOutlet weak var labelGatewayIP: NSTextField!
    @IBOutlet weak var labelUsageTime: NSTextField!
    @IBOutlet weak var labelUsageFlow: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.refreshUsageAndIP()
        let frequent:TimeInterval = 120
        let schedule:Timer = Timer.scheduledTimer(timeInterval: frequent, target: self, selector: #selector(SuccessInfoViewController.refreshUsageAndIP), userInfo: nil, repeats: true)
        print(schedule.isValid)
    }
    func refreshUsageAndIP() {
        let timeUsage = UsageProvider.timeUsage()
        let flowUsage = UsageProvider.flowUsage()
        if timeUsage != "" && flowUsage != "" {
            self.labelUsageTime.stringValue = timeUsage + " 分钟"
            self.labelUsageFlow.stringValue = flowUsage + " MB"
        }
        else {
            self.labelUsageTime.stringValue = "您还未登录"
            self.labelUsageFlow.stringValue = "您还未登录"
        }
        self.labelUserIP.stringValue = IPAddressProvider.currentIPAddresses().first!
        self.view.needsDisplay = true
    }
    
}
