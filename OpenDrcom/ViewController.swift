//
//  ViewController.swift
//  OpenDrcom
//
//  Created by 路伟饶 on 2017/6/30.
//  Copyright © 2017年 路伟饶. All rights reserved.
//

import Cocoa

/// 登录界面
class ViewController: NSViewController,NSTextFieldDelegate,LoginDelegate {
    
    /// 开关变量
    @IBOutlet weak var buttonIsSavedPassword: NSButton!
    @IBOutlet weak var textFieldUsername: NSTextField!
    @IBOutlet weak var textFieldPassword: NSSecureTextField!
    @IBOutlet weak var progress: NSProgressIndicator!
    
    /// 登录失败的状态
    private var isLoginFailed:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        设置文本框委托对象
        self.textFieldUsername.delegate = self
        self.textFieldPassword.delegate = self as NSTextFieldDelegate
//        获得本地存储对象
        let defaults = UserDefaults.standard
//        还原保存的用户名和密码
        if defaults.bool(forKey: "isSavePassword")==true {
            buttonIsSavedPassword.state = NSControl.StateValue(rawValue: 1)
            textFieldUsername.stringValue = defaults.object(forKey: "savedUser") as! String
            textFieldPassword.stringValue = defaults.object(forKey: "savedPassword") as! String
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
        let provider:LoginServiceProvider = LoginServiceProvider.init(delegate: self)
        self.progress.startAnimation(self)
        provider.login(user: username, passwd: password)
    }
    
    /// 登录成功的回调方法
    func didLoginSuccess() {
//        回到主线程继续操作
        DispatchQueue.main.sync {
//          加载条动画停止
            self.progress.stopAnimation(self)
//          跳转到登录成功页面
            self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "logInSuccessSegue"), sender: self)
//          关闭登录窗口
            self.view.window?.performClose(self)
        }
    }
    
    func didLoginFailed(errorCode: Int) {
//        回到主线程继续操作
        if Thread.isMainThread == true {
            self.progress.stopAnimation(self)
            let alert:NSAlert = NSAlert.init()
            alert.addButton(withTitle: "好")
            alert.alertStyle = NSAlert.Style.warning
            if errorCode == -1 {
                alert.messageText = "错误代码(-1)：请输入用户名"
            }
            else if errorCode == -2 {
                alert.messageText = "错误代码(-2)：请输入密码"
            }
            else if errorCode == 0 {
                alert.messageText = "错误代码(0)：未知错误"
            }
            alert.runModal()
            return
        }
        DispatchQueue.main.sync {
            //          加载条动画停止
            self.progress.stopAnimation(self)
            let alert:NSAlert = NSAlert.init()
            alert.addButton(withTitle: "好")
            alert.alertStyle = NSAlert.Style.warning
            if errorCode == -3 {
                alert.messageText = "错误代码(-3)：请求登录错误"
            }
            else if errorCode == -4 {
                alert.messageText = "错误代码(-4)：登录超时失败"
            }
            else if errorCode == -5 {
                alert.messageText = "错误代码(-5)：服务器错误"
            }
            else if errorCode == -6 {
                alert.messageText = "错误代码(-6)：用户名或密码错误"
            }
            else if errorCode == 0 {
                alert.messageText = "错误代码(0)：未知错误"
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
        }
        else {
            defaults.set("", forKey: "savedUser")
            defaults.set("", forKey: "savedPassword")
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
    
    /// 退出应用
    ///
    /// - Parameter sender: 消息发送者
    @IBAction func exitApplication(_ sender: Any) {
        self.view.window?.performClose(self)
    }
}
