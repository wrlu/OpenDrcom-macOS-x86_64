//
//  SuccessInfoViewController.swift
//  OpenDrcom
//
//  Created by 路伟饶 on 2017/6/30.
//  Copyright © 2017年 路伟饶. All rights reserved.
//

import Cocoa

/// 登录成功之后的界面
class SuccessInfoViewController: NSViewController,LoginDelegate {
    
    @IBOutlet weak var labelUserAccount: NSTextField!
    @IBOutlet weak var labelUserIP: NSTextField!
    @IBOutlet weak var labelBalance: NSTextField!
    @IBOutlet weak var labelUsageTime: NSTextField!
    @IBOutlet weak var labelUsageFlow: NSTextField!
    /// 总的重试次数
    @IBOutlet weak var labelTotalRetryTimes: NSTextField!
    /// 是否启用自动重连
    @IBOutlet weak var buttonIsAutoReconnect: NSButton!
    /// 计时器任务对象
    var schedule:Timer? = nil
    var password:String? = nil
    var retry = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "isAutoReconnect")==true {
            buttonIsAutoReconnect.state = NSControl.StateValue.on
        }
//        首先获取用量和IP地址
        self.refreshUsageAndIP()
//        计时器时间
        let frequent:TimeInterval = 15
//        每隔计时器时间，就会刷新一次用量和IP地址
        schedule = Timer.scheduledTimer(timeInterval: frequent, target: self, selector: #selector(SuccessInfoViewController.refreshUsageAndIP), userInfo: nil, repeats: true)
    }
    
    func getLoginParameter(account: String, password: String) {
        self.labelUserAccount.stringValue = account
        self.password = password
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
        let timeUsage = DrInfoProvider.timeUsage()
        let flowUsage = DrInfoProvider.flowUsage()
        let balanceUsage = DrInfoProvider.balanceUsage()
        let ipUsage = DrInfoProvider.inetAddress()
//        获取成功后设置界面文本
        if timeUsage != "" && flowUsage != "" && balanceUsage != "" && ipUsage != "" {
            self.labelUsageTime.stringValue = timeUsage + " 分钟"
            self.labelUsageFlow.stringValue = flowUsage + " MB"
            self.labelBalance.stringValue = balanceUsage + " 元"
            self.labelUserIP.stringValue = ipUsage
        }
        else {
            self.labelUsageTime.stringValue = "您还未登录"
            self.labelUsageFlow.stringValue = "您还未登录"
            self.labelBalance.stringValue = "您还未登录"
            self.labelUserIP.stringValue = "您还未登录"
            self.didLostConnection()
        }
//        强制界面刷新
        self.view.needsDisplay = true
    }
    
    @IBAction func autoReconnectValueChanged(_ sender: NSButton) {
        let defaults = UserDefaults.standard
        defaults.set(sender.state, forKey: "isAutoReconnect")
    }
    
    func didLostConnection() {
        if buttonIsAutoReconnect.state == NSControl.StateValue.on {
            let provider:LoginServiceProvider = LoginServiceProvider.init(delegate: self)
            provider.login(user: labelUserAccount.stringValue, passwd: password!)
        }
        else {
            self.didLogout()
        }
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
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "isAutoLogin")
        
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier.init("logOutSegue"), sender: self)
        self.view.window?.performClose(self)
    }
    
    func didLoginSuccess() {
        DispatchQueue.main.sync {
            labelTotalRetryTimes.integerValue = labelTotalRetryTimes.integerValue + 1
            self.view.needsDisplay = true
            retry = 0
        }
    }
    
    func didLoginFailed(errorCode: Int) {
        DispatchQueue.main.sync {
            labelTotalRetryTimes.integerValue = labelTotalRetryTimes.integerValue + 1
            self.view.needsDisplay = true
            retry = retry + 1
            if retry == 5 {
                self.didLogout()
            }
        }
    }
    
    
}
