//
//  ViewController.swift
//  OpenDrcom
//
//  Created by 路伟饶 on 2017/6/30.
//  Copyright © 2017年 路伟饶. All rights reserved.
//

import Cocoa

/// 登录界面
class ViewController: NSViewController,NSTextFieldDelegate {
    
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
            buttonIsSavedPassword.state = 1
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
        self.login(user: username, passwd: password)
    }
    
    /// 登录方法
    ///
    /// - Parameters:
    ///   - user: 用户名
    ///   - passwd: 密码
    func login(user:String,passwd:String) {
//        未输入用户名，弹窗提示
        if user == "" {
            let alert:NSAlert = NSAlert.init()
            alert.messageText = "错误：请输入用户名"
            alert.addButton(withTitle: "好")
            alert.alertStyle = NSAlertStyle.warning
            alert.runModal()
            return
        }
//        未输入密码，弹窗提示
        if passwd == "" {
            let alert:NSAlert = NSAlert.init()
            alert.messageText = "错误：请输入密码"
            alert.addButton(withTitle: "好")
            alert.alertStyle = NSAlertStyle.warning
            alert.runModal()
            return
        }
//        校园网网关地址
        let gatewayURL = URL.init(string: "http://192.168.100.251")
        let readData:Data
        do {
//            首先尝试连接网关
            try readData = Data.init(contentsOf: gatewayURL!)
            print(readData.count)
        }
        catch {
//            连接网关失败，弹窗提示网络不通
            print(error.localizedDescription)
            let alert:NSAlert = NSAlert.init()
            alert.messageText = "错误：网络连接失败"
            alert.addButton(withTitle: "好")
            alert.alertStyle = NSAlertStyle.warning
            alert.runModal()
            return
        }
//        异步调用Python模块进行登录
        DispatchQueue.global().async {
//            获得资源文件夹路径
            let resourcePath = Bundle.main.resourcePath
//            设置Python模块路径
            let pyModulePath = "sys.path.append('"+resourcePath!+"')"
//            获得Python参数
            let param = self.getParameter(user: user, passwd: passwd)
//            开始尝试登录
            self.isLoginFailed = false
            startLogin(pyModulePath,param)
//            Python模块在登录成功之后会不断发送Keep-alive包
//            因此上面的C函数不会返回
//            所以一旦上面的函数返回，则证明登录失败
            self.isLoginFailed = true
        };
//        在主线程中继续操作
//        加载条动画开始
        self.progress.startAnimation(self)
//        异步检查登录状态
        DispatchQueue.global().async {
            while true {
//              尝试从网关获取使用量，如果获取到了证明登录成功
                if UsageProvider.timeUsage() != "" && UsageProvider.flowUsage() != "" {
//                  跳转到登录成功页面
                    self.performSegue(withIdentifier: "logInSuccessSegue", sender: self)
//                  关闭登录窗口
                    self.view.window?.performClose(self)
                    break
                }
//              如果登录线程的C语言函数返回，则证明登录失败
                if self.isLoginFailed == true {
                    print("Login Failed!!!")
//                  弹窗提示，一般情况下都是用户名或密码错误，也不排除是忽然断网，学校的网总这样，呵呵
                    let alert:NSAlert = NSAlert.init()
                    alert.messageText = "错误：用户名或密码错误，或网络连接失败"
                    alert.addButton(withTitle: "好")
                    alert.alertStyle = NSAlertStyle.warning
                    alert.runModal()
                    break
                }
            }
//          加载条动画停止
            self.progress.stopAnimation(self)
        }
    }
    
    /// 生成Python参数的方法
    ///
    /// - Parameters:
    ///   - user: 用户名
    ///   - passwd: 密码
    /// - Returns: Python参数，格式为：用户名/*DRCOM*/密码/*DRCOM*/IP地址
    func getParameter(user:String,passwd:String) -> String {
        var resultParam = user + "/*DRCOM*/" + passwd + "/*DRCOM*/"
        resultParam += IPAddressProvider.currentIPAddresses().first!
        print(resultParam)
        return resultParam
    }
    
    /// 保存密码按钮状态变化的方法
    ///
    /// - Parameter sender: 消息发送者
    @IBAction func savePasswordValueChanged(_ sender: NSButton) {
        let defaults = UserDefaults.standard
        defaults.set(sender.state, forKey: "isSavePassword")
        if sender.state == 1 {
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
        if buttonIsSavedPassword.state == 1 {
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
