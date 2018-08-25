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

/// 登录界面
class LoginViewController: NSViewController,NSTextFieldDelegate,LoginDelegate {
    
    var provider:LoginServiceProvider? = nil
    /// 保存密码选项
    @IBOutlet weak var buttonIsSavedPassword: NSButton!
    /// 自动登录选项
    @IBOutlet weak var buttonIsAutoLogin: NSButton!
    /// 用户名输入框
    @IBOutlet weak var textFieldUsername: NSTextField!
    /// 密码输入框
    @IBOutlet weak var textFieldPassword: NSSecureTextField!
    /// 加载进度条
    @IBOutlet weak var progress: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        设置文本框委托对象
        self.textFieldUsername.delegate = self
        self.textFieldPassword.delegate = self
//        初始化登录服务提供者
        provider = LoginServiceProvider.init(loginDelegate: self, logoutDelegate: nil)
//        获得本地存储对象
        let defaults = UserDefaults.standard
//        检查保存密码状态
        if defaults.bool(forKey: "isSavePassword")==true {
            buttonIsSavedPassword.state = NSControl.StateValue.on
            textFieldUsername.stringValue = defaults.object(forKey: "savedUser") as! String
            textFieldPassword.stringValue = defaults.object(forKey: "savedPassword") as! String
//            在保存密码的前提下才允许自动登录
            buttonIsAutoLogin.isEnabled = true
        }
//        检查自动登录状态
        if defaults.bool(forKey: "isAutoLogin")==true {
            buttonIsAutoLogin.state = NSControl.StateValue.on
//            如果不是刚刚从注销返回，则执行自动登录操作
            if defaults.bool(forKey: "isLoadFromLogout")==false {
                clickLoginButton(self)
            }
        }
    }
    
    /// 点按登录按钮调用的方法
    ///
    /// - Parameter sender: 消息发送者
    @IBAction func clickLoginButton(_ sender: Any) {
//        获得用户名和密码字符串
        let username = textFieldUsername.stringValue
        let password = textFieldPassword.stringValue
//        在登录之前，先使用回调方法通知保存现在输入的用户名和密码
//        因为用户不离开文本框直接点按登录按钮，该文本框不会触发回调
//        所以在这里为了保存的用户名和密码的正确，手动调用了回调方法
        self.controlTextDidEndEditing(Notification.init(name: Notification.Name.init(rawValue: "Login")))
//        开始登录操作
        self.progress.startAnimation(self)
//        开始登录
        provider?.login(user: username, passwd: password)
    }
    
    /// 登录成功的回调方法
    func didLoginSuccess() {
//        回到主线程继续操作
        DispatchQueue.main.sync {
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: "isLoadFromLogout")
//          加载条动画停止
            self.progress.stopAnimation(self)
//          跳转到登录成功页面
            self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "logInSuccessSegue"), sender: self)
//          关闭登录窗口
            self.view.window?.performClose(self)
        }
    }
    
    /// Segue跳转前调用的方法
    ///
    /// - Parameters:
    ///   - segue: Segue对象
    ///   - sender: 消息发送者
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
//        登录成功跳转Segue
        if segue.identifier?.rawValue == "logInSuccessSegue"{
            let destWindow = segue.destinationController as! NSWindowController;
            let viewController = destWindow.contentViewController as! SuccessInfoViewController
//            向登录成功页面传入账号和密码
            viewController.getLoginParameter(account: self.textFieldUsername.stringValue, password: self.textFieldPassword.stringValue)
        }
    }
    
    /// 登录失败的回调方法
    ///
    /// - Parameter reason: 失败原因
    func didLoginFailed(reason:String?) {
        if Thread.isMainThread == true {
            self.progress.stopAnimation(self)
            let alert:NSAlert = NSAlert.init()
            alert.addButton(withTitle: "好")
            alert.alertStyle = NSAlert.Style.warning
            alert.messageText = "出现错误:"
            if reason != nil {
                alert.messageText.append(" ")
                alert.messageText.append(reason!)
            }
            alert.runModal()
            return
        }
//        回到主线程继续操作
        DispatchQueue.main.sync {
//          加载条动画停止
            self.progress.stopAnimation(self)
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
    
    /// 保存密码按钮状态变化的方法
    ///
    /// - Parameter sender: 消息发送者
    @IBAction func savePasswordValueChanged(_ sender: NSButton) {
        let defaults = UserDefaults.standard
        defaults.set(sender.state, forKey: "isSavePassword")
        if sender.state.rawValue == 1 {
            defaults.set(textFieldUsername.stringValue, forKey: "savedUser")
            defaults.set(textFieldPassword.stringValue, forKey: "savedPassword")
            buttonIsAutoLogin.isEnabled = true
        } else {
            defaults.set("", forKey: "savedUser")
            defaults.set("", forKey: "savedPassword")
            buttonIsAutoLogin.state = NSControl.StateValue.off
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: "isAutoLogin")
            defaults.set(false, forKey: "isLoadFromLogout")
            buttonIsAutoLogin.isEnabled = false
        }
    }
    
    /// 自动登录按钮状态变化的方法
    ///
    /// - Parameter sender: 消息发送者
    @IBAction func autoLoginValueChanged(_ sender: NSButton) {
        let defaults = UserDefaults.standard
        defaults.set(sender.state, forKey: "isAutoLogin")
        if sender.state == NSControl.StateValue.on {
            defaults.set(false, forKey: "isLoadFromLogout")
        }
    }
    
    /// 监听输入内容变化的回调方法
    ///
    /// - Parameter obj: 通知对象
    override func controlTextDidEndEditing(_ obj: Notification) {
        if buttonIsSavedPassword.state.rawValue == 1 {
            let defaults = UserDefaults.standard
            defaults.set(textFieldUsername.stringValue, forKey: "savedUser")
            defaults.set(textFieldPassword.stringValue, forKey: "savedPassword")
        }
    }
    
    /// 获得注销状态参数，忽略自动登录参数，实现注销返回后不立即自动登录
    func getLogoutParameter() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "isLoadFromLogout")
    }
    
    /// 退出应用
    ///
    /// - Parameter sender: 消息发送者
    @IBAction func exitApplication(_ sender: Any) {
        self.view.window?.performClose(self)
    }
}
