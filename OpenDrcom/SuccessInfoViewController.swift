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
        let timeUsage = UsageProvider.timeUsage()
        let flowUsage = UsageProvider.flowUsage()
        if timeUsage != "" && flowUsage != "" {
            labelUsageTime.stringValue = timeUsage + " 分钟"
            labelUsageFlow.stringValue = flowUsage + " MB"
        }
        else {
            labelUsageTime.stringValue = "您还未登录"
            labelUsageFlow.stringValue = "您还未登录"
        }
        labelUserIP.stringValue = IPAddressProvider.currentIPAddresses().first!
    }
    
}
