//
//  ViewController.swift
//  OpenDrcom
//
//  Created by 路伟饶 on 2017/6/30.
//  Copyright © 2017年 路伟饶. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var buttonIsSavedPassword: NSButton!
    @IBOutlet weak var buttonIsAutoLogin: NSButton!
    @IBOutlet weak var textFieldUsername: NSTextField!
    @IBOutlet weak var textFieldPassword: NSSecureTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "isSavePassword")==true {
            buttonIsSavedPassword.state = 1
            buttonIsAutoLogin.isEnabled = true
            textFieldUsername.stringValue = defaults.object(forKey: "savedUser") as! String
            textFieldPassword.stringValue = defaults.object(forKey: "savedPassword") as! String
        }
        if defaults.bool(forKey: "isAutoLogin")==true {
            buttonIsAutoLogin.state = 1
            self.clickLoginButton(self)
        }
    }
    @IBAction func clickLoginButton(_ sender: Any) {
        let username = textFieldUsername.stringValue
        let password = textFieldPassword.stringValue
        self.login(user: username, passwd: password)
        self.performSegue(withIdentifier: "logInSuccessSegue", sender: self)
    }
    
    func login(user:String,passwd:String) {
        if user == "" {
            print("No Username input")
        }
        if passwd == "" {
            print("No password input")
        }
        DispatchQueue.global().async {
            let resourcePath = Bundle.main.resourcePath
            let pyModulePath = "sys.path.append('"+resourcePath!+"')"
            let param = self.getParameter(user: user, passwd: passwd)
            startLogin(pyModulePath,param)
        };
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
             buttonIsAutoLogin.isEnabled = true
            defaults.set(textFieldUsername.stringValue, forKey: "savedUser")
            defaults.set(textFieldPassword.stringValue, forKey: "savedPassword")
        }
        else {
             buttonIsAutoLogin.isEnabled = false
            buttonIsAutoLogin.state = 0
            defaults.set(false, forKey: "isAutoLogin")
            defaults.set("", forKey: "savedUser")
            defaults.set("", forKey: "savedPassword")
        }
    }
    @IBAction func autoLoginValueChanged(_ sender: NSButton) {
        let defaults = UserDefaults.standard
        defaults.set(sender.state, forKey: "isAutoLogin")
    }
    
}
