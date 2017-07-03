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
    var schedule:Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.refreshUsageAndIP()
        let frequent:TimeInterval = 15
        schedule = Timer.scheduledTimer(timeInterval: frequent, target: self, selector: #selector(SuccessInfoViewController.refreshUsageAndIP), userInfo: nil, repeats: true)
    }
    
    func refreshUsageAndIP() {
        let gatewayURL = URL.init(string: "http://192.168.100.251")
        let readData:Data
        do {
            try readData = Data.init(contentsOf: gatewayURL!)
            print(readData.count)
        }
        catch {
            print(error.localizedDescription)
            schedule?.invalidate()
            let alert:NSAlert = NSAlert.init()
            alert.messageText = "错误：网络连接失败"
            alert.addButton(withTitle: "好")
            alert.alertStyle = NSAlertStyle.warning
            if alert.runModal() == NSAlertFirstButtonReturn {
                self.performSegue(withIdentifier: "logOutSegue", sender: self)
                self.view.window?.performClose(self)
            }
            return
        }
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
