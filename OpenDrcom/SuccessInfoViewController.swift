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
            labelUserIP.stringValue = IPAddressProvider.currentIPAddresses().first!
        }
        else {
            labelUsageTime.stringValue = "无法获取分钟数"
            labelUsageFlow.stringValue = "无法获取流量"
            labelUserIP.stringValue = "无法获取IP"
        }
        
    }
    
}
