//
//  SuccessInfoViewController.swift
//  OpenDrcom
//
//  Created by 路伟饶 on 2017/6/30.
//  Copyright © 2017年 路伟饶. All rights reserved.
//

import Cocoa

/// 登录成功之后的界面
class SuccessInfoViewController: NSViewController {
    
    /// 开关变量
    @IBOutlet weak var labelUserIP: NSTextField!
    @IBOutlet weak var labelGatewayIP: NSTextField!
    @IBOutlet weak var labelUsageTime: NSTextField!
    @IBOutlet weak var labelUsageFlow: NSTextField!
    
    /// 计时器任务对象
    var schedule:Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
//        首先获取用量和IP地址
        self.refreshUsageAndIP()
//        计时器时间
        let frequent:TimeInterval = 15
//        每隔计时器时间，就会刷新一次用量和IP地址
        schedule = Timer.scheduledTimer(timeInterval: frequent, target: self, selector: #selector(SuccessInfoViewController.refreshUsageAndIP), userInfo: nil, repeats: true)
    }
    
    /// 刷新使用时长、使用流量和IP地址的方法
    @objc func refreshUsageAndIP() {
        let gatewayURL = URL.init(string: "http://192.168.100.200")
        let readData:Data
        do {
//            尝试连接网关
            try readData = Data.init(contentsOf: gatewayURL!)
            print(readData.count)
        }
        catch {
//            网关连接失败，证明已经断网
            print(error.localizedDescription)
            self.didLogout()
            return
        }
//        获取用量
        let timeUsage = UsageProvider.timeUsage()
        let flowUsage = UsageProvider.flowUsage()
//        获取成功后设置界面文本
        if timeUsage != "" && flowUsage != "" {
            self.labelUsageTime.stringValue = timeUsage + " 分钟"
            self.labelUsageFlow.stringValue = flowUsage + " MB"
        }
        else {
            self.labelUsageTime.stringValue = "您还未登录"
            self.labelUsageFlow.stringValue = "您还未登录"
            self.didLogout()
        }
//        获取IP地址
        self.labelUserIP.stringValue = IPAddressProvider.currentIPAddresses().first!
//        强制界面刷新
        self.view.needsDisplay = true
    }
    
    
    /// 执行注销操作并返回登录界面
    func didLogout() {
//        取消计时器
        schedule?.invalidate()
//        弹窗提示用户断网
        let alert:NSAlert = NSAlert.init()
        alert.messageText = "错误：网络连接失败"
        alert.addButton(withTitle: "好")
        alert.alertStyle = NSAlert.Style.warning
//        点按确定按钮之后进入if
        if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
//            跳转重新登录
            self.reLogin(self)
        }
    }
    
    
    /// 回到登录界面
    ///
    /// - Parameter sender: 消息发送者
    @IBAction func reLogin(_ sender: Any) {
//        跳转回到登录页面
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier.init("logOutSegue"), sender: self)
        self.view.window?.performClose(self)
    }
    
    
}
