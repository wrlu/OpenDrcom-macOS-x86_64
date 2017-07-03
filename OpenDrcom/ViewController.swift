//
//  ViewController.swift
//  OpenDrcom
//
//  Created by 路伟饶 on 2017/6/30.
//  Copyright © 2017年 路伟饶. All rights reserved.
//

import Cocoa

class ViewController: NSViewController,NSTextFieldDelegate {

    @IBOutlet weak var buttonIsSavedPassword: NSButton!
    @IBOutlet weak var buttonIsAutoLogin: NSButton!
    @IBOutlet weak var textFieldUsername: NSTextField!
    @IBOutlet weak var textFieldPassword: NSSecureTextField!
    @IBOutlet weak var progress: NSProgressIndicator!
    
    private var isLoginFailed:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.textFieldUsername.delegate = self
        self.textFieldPassword.delegate = self as NSTextFieldDelegate
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "isSavePassword")==true {
            buttonIsSavedPassword.state = 1
//            buttonIsAutoLogin.isEnabled = true
            textFieldUsername.stringValue = defaults.object(forKey: "savedUser") as! String
            textFieldPassword.stringValue = defaults.object(forKey: "savedPassword") as! String
        }
//        if defaults.bool(forKey: "isAutoLogin")==true {
//            buttonIsAutoLogin.state = 1
//            self.clickLoginButton(self)
//        }
    }
    @IBAction func clickLoginButton(_ sender: Any) {
        let username = textFieldUsername.stringValue
        let password = textFieldPassword.stringValue
        self.controlTextDidEndEditing(Notification.init(name: Notification.Name.init(rawValue: "Login")))
        self.login(user: username, passwd: password)
    }
    
    func login(user:String,passwd:String) {
        if user == "" {
            let alert:NSAlert = NSAlert.init()
            alert.messageText = "错误：请输入用户名"
            alert.addButton(withTitle: "好")
            alert.alertStyle = NSAlertStyle.warning
            alert.runModal()
            return
        }
        if passwd == "" {
            let alert:NSAlert = NSAlert.init()
            alert.messageText = "错误：请输入密码"
            alert.addButton(withTitle: "好")
            alert.alertStyle = NSAlertStyle.warning
            alert.runModal()
            return
        }
        let gatewayURL = URL.init(string: "http://192.168.100.251")
        let readData:Data
        do {
            try readData = Data.init(contentsOf: gatewayURL!)
            print(readData.count)
        }
        catch {
            print(error.localizedDescription)
            let alert:NSAlert = NSAlert.init()
            alert.messageText = "错误：网络连接失败"
            alert.addButton(withTitle: "好")
            alert.alertStyle = NSAlertStyle.warning
            alert.runModal()
            return
        }
        DispatchQueue.global().async {
            let resourcePath = Bundle.main.resourcePath
            let pyModulePath = "sys.path.append('"+resourcePath!+"')"
            let param = self.getParameter(user: user, passwd: passwd)
            self.isLoginFailed = false
            startLogin(pyModulePath,param)
            self.isLoginFailed = true
        };
        self.progress.startAnimation(self)
        while true {
            if UsageProvider.timeUsage() != "" && UsageProvider.flowUsage() != "" {
                self.performSegue(withIdentifier: "logInSuccessSegue", sender: self)
                self.view.window?.performClose(self)
                break
            }
            if isLoginFailed == true {
                print("Login Failed!!!")
                let alert:NSAlert = NSAlert.init()
                alert.messageText = "错误：用户名或密码错误，或网络连接失败"
                alert.addButton(withTitle: "好")
                alert.alertStyle = NSAlertStyle.warning
                alert.runModal()
                break
            }
        }
        self.progress.stopAnimation(self)
    }
    func getParameter(user:String,passwd:String) -> String {
        var resultParam = user + "/*DRCOM*/" + passwd + "/*DRCOM*/"
        resultParam += IPAddressProvider.currentIPAddresses().first!
        print(resultParam)
        return resultParam
    }
    
    @IBAction func savePasswordValueChanged(_ sender: NSButton) {
        let defaults = UserDefaults.standard
        defaults.set(sender.state, forKey: "isSavePassword")
        if sender.state == 1 {
//             buttonIsAutoLogin.isEnabled = true
            defaults.set(textFieldUsername.stringValue, forKey: "savedUser")
            defaults.set(textFieldPassword.stringValue, forKey: "savedPassword")
        }
        else {
//            buttonIsAutoLogin.isEnabled = false
//            buttonIsAutoLogin.state = 0
//            defaults.set(false, forKey: "isAutoLogin")
            defaults.set("", forKey: "savedUser")
            defaults.set("", forKey: "savedPassword")
        }
    }
//    @IBAction func autoLoginValueChanged(_ sender: NSButton) {
//        let defaults = UserDefaults.standard
//        defaults.set(sender.state, forKey: "isAutoLogin")
//    }
    @IBAction func clickCanelButton(_ sender: Any) {
        self.performSegue(withIdentifier: "logInSuccessSegue", sender: self)
        self.view.window?.performClose(self)
    }
    override func controlTextDidEndEditing(_ obj: Notification) {
        if buttonIsSavedPassword.state == 1 {
            let defaults = UserDefaults.standard
            defaults.set(textFieldUsername.stringValue, forKey: "savedUser")
            defaults.set(textFieldPassword.stringValue, forKey: "savedPassword")
        }
    }
}
