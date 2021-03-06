/**
 * Copyright (c) 2017, 小路.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms and conditions of the GNU General Public License, version 3,
 * as published by the Free Software Foundation.
 *
 * This program is distributed in the hope it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 */

import Cocoa

/// 登录成功之后的界面
class SuccessInfoViewController: NSViewController,LoginDelegate,LogoutDelegate,DrInfoProviderDelegate {
    var drProvider:DrInfoProvider? = nil
    var provider:LoginServiceProvider? = nil
    
    /// 登入用户名文本
    @IBOutlet weak var labelUserAccount: NSTextField!
    /// 本地IP文本
    @IBOutlet weak var labelUserIP: NSTextField!
    /// 本地IP加载符号
    @IBOutlet weak var userIPLoader: NSProgressIndicator!
    /// 本地IP状态指示器（图片）
    @IBOutlet weak var userIPLoadImage: NSImageView!
    /// 用户余额文本
    @IBOutlet weak var labelBalance: NSTextField!
    /// 用户使用时长文本
    @IBOutlet weak var labelUsageTime: NSTextField!
    /// 用户使用流量文本
    @IBOutlet weak var labelUsageFlow: NSTextField!
    /// 是否启用自动重连
    @IBOutlet weak var buttonIsAutoReconnect: NSButton!
    /// 计时器任务对象
    var schedule:Timer? = nil
    var password:String? = nil
    
    var retry = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userIPLoader.startAnimation(self)
        userIPLoadImage.image = NSImage.init(named: NSImage.Name.statusUnavailable)
        drProvider = DrInfoProvider.init(delegate: self)
        provider = LoginServiceProvider.init(loginDelegate: self, logoutDelegate: self)
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "isAutoReconnect")==true {
            buttonIsAutoReconnect.state = NSControl.StateValue.on
        }
//        计时器时间，设定为1分钟一刷新
        let frequent:TimeInterval = 60
//        每隔计时器时间，就会刷新一次用量和IP地址
            schedule = Timer.scheduledTimer(withTimeInterval: frequent, repeats: true, block: { (schedule) in
                self.refreshUsageAndIP()
            })
    }
    
    /// 刷新用量和IP信息
    func refreshUsageAndIP() {
        userIPLoader.startAnimation(self)
        drProvider?.searchGateway()
    }
    
    func finishRefreshUsageAndIP() {
        //        获取用量
        let timeUsage = drProvider?.timeUsage()
        let flowUsage = drProvider?.flowUsage()
        let balanceUsage = drProvider?.balanceUsage()
        let ipv4Private = drProvider?.ipv4Private()
        DispatchQueue.main.sync {
//          获取成功后设置界面文本
            if timeUsage != nil && flowUsage != nil && balanceUsage != nil && ipv4Private != nil {
                if Int(timeUsage!)! < 60 {
                    self.labelUsageTime.stringValue = timeUsage! + " 分"
                }
                else if Int(timeUsage!)! >= 60 && Int(timeUsage!)! < 1440 {
                    self.labelUsageTime.stringValue = String(Int(timeUsage!)!/60) + " 时 " + String(Int(timeUsage!)!%60) + " 分"
                } else if Int(timeUsage!)! >= 1440 {
                    self.labelUsageTime.stringValue = String(Int(timeUsage!)!/1440) + " 天 " + String((Int(timeUsage!)!%1440)/60) + " 时 " + String((Int(timeUsage!)!%1440)%60) + " 分"
                }
                if Float(flowUsage!)! < 1024 {
                    self.labelUsageFlow.stringValue = flowUsage! + " MB"
                }
                else if Float(flowUsage!)! >= 1024 {
                    self.labelUsageFlow.stringValue = String(Float(flowUsage!)!/1024) + "GB"
                }
                self.labelBalance.stringValue = balanceUsage! + " 元"
                self.labelUserIP.stringValue = "校园网：" + ipv4Private!
            } else {
                self.labelUsageTime.stringValue = "您还未登录"
                self.labelUsageFlow.stringValue = "您还未登录"
                self.labelBalance.stringValue = "您还未登录"
                self.didLostConnection()
            }
//          强制界面刷新
            self.view.needsDisplay = true
            userIPLoader.stopAnimation(self)
            userIPLoadImage.image = NSImage.init(named: NSImage.Name.statusAvailable)
        }
    }
    
    /// 获得登录参数
    ///
    /// - Parameters:
    ///   - account: 用户名
    ///   - password: 密码
    func getLoginParameter(account: String, password: String) {
        self.labelUserAccount.stringValue = account
        self.password = password
    }
    
    /// 自动重拨值改变回调方法
    ///
    /// - Parameter sender: 消息发送者
    @IBAction func autoReconnectValueChanged(_ sender: NSButton) {
        let defaults = UserDefaults.standard
        defaults.set(sender.state, forKey: "isAutoReconnect")
    }
    
    /// 丢失连接调用的方法
    func didLostConnection() {
        if buttonIsAutoReconnect.state == NSControl.StateValue.on {
            provider?.login(user: labelUserAccount.stringValue, passwd: password!)
        } else {
            self.didRelogin()
        }
    }
    
    /// 返回登录界面
    func didRelogin() {
//        获得本地存储对象
        let defaults = UserDefaults.standard
//        取消计时器
        schedule?.invalidate()
//        弹窗提示用户断网
        userIPLoadImage.image = NSImage.init(named: NSImage.Name.statusUnavailable)
        let alert:NSAlert = NSAlert.init()
        alert.messageText = "错误：网络连接失败"
        alert.addButton(withTitle: "好")
//        如果开启了自动登录选项，才会显示重试按钮
//        否则回到登录页面之后
        if defaults.bool(forKey: "isAutoLogin")==true {
            alert.addButton(withTitle: "重试")
        }
        alert.alertStyle = NSAlert.Style.warning
//        runModal()会阻塞程序，直到用户做出选择
        let response = alert.runModal()
//        选择第一个按钮也就是“好”，返回登录页面不再尝试
        if response == NSApplication.ModalResponse.alertFirstButtonReturn {
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "isLoadFromLogout")
            self.performSegue(withIdentifier: NSStoryboardSegue.Identifier.init("logOutSegue"), sender: self)
            self.view.window?.performClose(self)
//        选择第二个按钮也就是“重试”，返回登录页面并立即重新尝试
        } else if response == NSApplication.ModalResponse.alertSecondButtonReturn {
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: "isLoadFromLogout")
            self.performSegue(withIdentifier: NSStoryboardSegue.Identifier.init("logOutSegue"), sender: self)
            self.view.window?.performClose(self)
        }
    }
    
    /// 点击注销按钮调用的方法
    ///
    /// - Parameter sender: 消息发送者
    @IBAction func clickLogoutButton(_ sender: NSButton) {
        let alert:NSAlert = NSAlert.init()
        alert.messageText = "是否注销登录？注销后将无法访问互联网。"
        alert.addButton(withTitle: "好")
        alert.addButton(withTitle: "取消")
        alert.alertStyle = NSAlert.Style.warning
//        执行注销操作
        if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
            provider?.logout()
        }
    }
    
    func didLoginSuccess() {
        DispatchQueue.main.sync {
            self.view.needsDisplay = true
            retry = 0
        }
    }
    
    func didLoginFailed(reason: String?) {
        DispatchQueue.main.sync {
            self.view.needsDisplay = true
            retry = retry + 1
            if retry >= 5 {
                self.didRelogin()
            } else {
                self.didLostConnection()
            }
        }
    }
    
    func didLogoutSuccess() {
        DispatchQueue.main.sync {
//        取消计时器
            schedule?.invalidate()
//        跳转登录页面
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "isLoadFromLogout")
            self.performSegue(withIdentifier: NSStoryboardSegue.Identifier.init("logOutSegue"), sender: self)
            self.view.window?.performClose(self)
        }
    }
    
    func didLogoutFailed(reason: String?) {
        DispatchQueue.main.sync {
            let alert:NSAlert = NSAlert.init()
            alert.addButton(withTitle: "好")
            alert.alertStyle = NSAlert.Style.warning
            alert.messageText = "出现错误:"
            if reason != nil {
                alert.messageText.append(" ")
                alert.messageText.append(reason!)
            }
            alert.runModal()
        }
    }
}
